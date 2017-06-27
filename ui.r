library(shinythemes)
library(DT)

ui <- fluidPage(theme = shinytheme("cerulean"),
                tagList(
                  tags$head(
                    tags$link(rel="stylesheet", type="text/css",href="style.css"),
                    tags$script(type="text/javascript", src = "busy.js")
                  )
                ),
                
                #This block gives us all the inputs:
                mainPanel(
                  headerPanel('Shiny Blast!'),
                  textAreaInput('query', 'Input sequence:', value = "", placeholder = "", width = "600px", height="200px"),
                  selectInput("db", "Databse:", choices=c("NvERTx.4","nr"), width="120px"),
                  div(style="display:inline-block",
                      selectInput("program", "Program:", choices=c("blastn","tblastn"), width="100px")),
                  div(style="display:inline-block",
                      selectInput("eval", "e-value:", choices=c(1,0.001,1e-4,1e-5,1e-10), width="120px")),
                  actionButton("blast", "BLAST!")
                ),
                
                #this snippet generates a progress indicator for long BLASTs
                div(class = "busy",  
                    p("Calculation in progress.."), 
                    img(src="https://i.stack.imgur.com/8puiO.gif", height = 100, width = 100,align = "center")
                ),
                
                #Basic results output
                mainPanel(
                  h4("Results"),
                  DT::dataTableOutput("blastResults"),
                  p("Alignment:", tableOutput("clicked") ),
                  verbatimTextOutput("alignment")
                )
)
