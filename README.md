# Shiny Server Analysis
Using the [rsconnect](https://cran.r-project.org/web/packages/rsconnect/) library to analyse stats on existing [shinyapps.io](https://www.shinyapps.io/) apps running under Scotland organisation account. Requires membership of the Shiny organisation.  

It is necessary to connect to Shiny server wish to analyse in R Studio and then run code in this repository via R Studio.  

To connect:  

Tools > Global Options > Publishing > Publishing Accounts and specify connection information and login details for Shiny Server.

The main analysis is run from `get_app_info.R`. This includes analysis on a manually maintained Google Sheet that was used as a register of the apps. This should be downloaded first of all as a CSV file and placed in the  `inputs` folder.  

After running this script to generate results CSV for the current date in `outputs`, a formatted Excel sheet of results, including summary of apps per organisation can be created by running `excel_output.R`