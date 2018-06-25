# Shiny_BLAST
## Description: 
This app runs BLAST locally then parses and displays the results. It can be directly integrated into existing apps or function as a standalone blast server. 

A Blog post describing the code can be found <a href="http://www.2-bitbio.com/2017/06/running-blast-in-shiny-web-application.html">here</a>

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
In the ui.r file, change line 4 `custom_db <- c("LvTx")` to include  the name of your databases. 
Note that in the current configuration when nr is selected a 'remote' BLAST is called so this database does not need to be stored locally. 

In the server.r file, change lines 8 and 9 to add your own database names and paths (they must match the names in the ui.r files). 
Be sure that you include the path to the databases like so: 
```
  custom_db <- c("YOUR_DATABASE NAME")
  custom_db_path <- c("/PATH_TO_YOUR_DATABSE)
  
```
