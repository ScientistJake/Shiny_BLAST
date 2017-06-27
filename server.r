require(XML)
library(plyr)
library(dplyr)
library(DT)

server <- function(input, output, session){
  
  blastresults <- eventReactive(input$blast, {
    
    #gather input and set up temp file
    query <- input$query
    tmp <- tempfile(fileext = ".fa")
    
    #if else chooses the right database
    if (input$db =="NvERTx.4"){
      db <- c("/Users/Jake/Documents/GitHub_repos/NvER_plotter_django/nemVec_ER/blast_db/NvERTx.4")
      remote <- c("")
    } else {
      db <- c("nr")
      #add remote option for nr since we don't have a local copy
      remote <- c("-remote")
    }
    
    #this makes sure the fasta is formatted properly
    if (startsWith(query, ">")){
      writeLines(query, tmp)
    } else {
      writeLines(paste0(">Query\n",query), tmp)
    }
    
    #calls the blast
    data <- system(paste0(input$program," -query ",tmp," -db ",db," -dust no -evalue ",input$eval," -outfmt 5 -max_hsps 1 -max_target_seqs 10 ",remote), intern = T)
    xmlParse(data)
    }, ignoreNULL= T)

  #Now to parse the results...
  parsedresults <- reactive({
    if (is.null(blastresults())){}
    else {
      xmltop = xmlRoot(blastresults())
      
      #the first chunk is for multi-fastas
      results <- xpathApply(blastresults(), '//Iteration',function(row){
        query_ID <- getNodeSet(row, 'Iteration_query-def') %>% sapply(., xmlValue)
        hit_IDs <- getNodeSet(row, 'Iteration_hits//Hit//Hit_id') %>% sapply(., xmlValue)
        hit_length <- getNodeSet(row, 'Iteration_hits//Hit//Hit_len') %>% sapply(., xmlValue)
        bitscore <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_bit-score') %>% sapply(., xmlValue)
        eval <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_evalue') %>% sapply(., xmlValue)
        cbind(query_ID,hit_IDs,hit_length,bitscore,eval)
      })
      #this ensures that NAs get added for no hits
      results <-  rbind.fill(lapply(results,function(y){as.data.frame((y),stringsAsFactors=FALSE)}))
    }
  })
  
  #makes the datatable
  output$blastResults <- renderDataTable({
    if (is.null(blastresults())){
    } else {
      parsedresults()
    }
  }, selection="single")
  
  #this chunk gets the alignemnt information from a clicked row
  output$clicked <- renderTable({
    if(is.null(input$blastResults_rows_selected)){}
    else{
      xmltop = xmlRoot(blastresults())
      clicked = input$blastResults_rows_selected
      tableout<- data.frame(parsedresults()[clicked,])
      
      tableout <- t(tableout)
      names(tableout) <- c("")
      rownames(tableout) <- c("Query ID","Hit ID", "Length", "Bit Score", "e-value")
      colnames(tableout) <- NULL
      data.frame(tableout)
    }
  },rownames =T,colnames =F)
  
  #this chunk makes the alignments for clicked rows
  output$alignment <- renderText({
    if(is.null(input$blastResults_rows_selected)){}
    else{
      xmltop = xmlRoot(blastresults())
      
      clicked = input$blastResults_rows_selected
        
      #loop over the xml to get the alignments
      align <- xpathApply(blastresults(), '//Iteration',function(row){
        top <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_qseq') %>% sapply(., xmlValue)
        mid <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_midline') %>% sapply(., xmlValue)
        bottom <- getNodeSet(row, 'Iteration_hits//Hit//Hit_hsps//Hsp//Hsp_hseq') %>% sapply(., xmlValue)
        rbind(top,mid,bottom)
      })
        
      #split the alignments every 40 carachters to get a "wrapped look"
      alignx <- do.call("cbind", align)
      splits <- strsplit(gsub("(.{40})", "\\1,", alignx[1:3,clicked]),",")
      
      #paste them together with returns '\n' on the breaks
      split_out <- lapply(1:length(splits[[1]]),function(i){
        rbind(paste0("Q-",splits[[1]][i],"\n"),paste0("M-",splits[[2]][i],"\n"),paste0("H-",splits[[3]][i],"\n"))
      })
      unlist(split_out)
    }
  })
}
#phew...
