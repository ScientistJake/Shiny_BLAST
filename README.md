# Shiny_BLAST
## Description: 
This app runs BLAST locally then parses and displays the results. It can be directly integrated into existing apps or function as a standalone blast server.

## Requirements: 
* Unix like environment
* [Current BLAST executables](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download)
* The following R packages
  1. shiny
  2. plyr
  3. dplyr
  4. XML
  5. DT
  6. shinythemes (optional) 

## Usage: 
In the ui.r file, change line 16 `choices=c("NvERTx.4","nr")` to include your databases. 
Note that in the current configuration when nr is selected a 'remote' BLAST is called so this database does not need to be stored locally. 

In the server.r file, change lines 15 to 22 to add your own databases (they must match those in the ui.r files). 
Be sure that you include the path to the databases like so: 
```
if (input$db =="YOUR_DATABASE"){
      db <- c("/PATH_TO_DATABASE/DATABASE_NAME")
      remote <- c("")
```
