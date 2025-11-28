# shinyadmin

The code in this repository is used to assist with administration of the Scottish Public Sector [shinyapps.io](https://www.shinyapps.io/) account (scotland.shinyapps.io). 

## Prerequisites

1.  You must be a member of the `scotland` shinyapps.io account.

2.  You must have registered the `scotland` account in RStudio using an account token and secret. This can be done using the following code:

    ```
    rsconnect::setAccountInfo(
      name   = "scotland",
      token  = "",
      secret = ""
    )
    ```
    
3.  You must have access to the `AdministrationShinyapps` ADM database used to store the data.

4.  You must have access to the Microsoft Form used to collect contact data, and the Excel spreadsheet where responses are stored.

    * If you are not the owner of the Excel spreadsheet, you will need to download a copy before running any code.

5.  You must have the `shinyadmin` package installed. To do this in RStudio, navigate to the 'Build' tab (usually in top-right pane) and click 'Install'.


## Data

There are three sources of data:

1.  App data from the shinyapps.io server

    A snapshot of this data is taken in script 1 and written to ADM in the table `server_apps`.

2.  Contact data collected via a Microsoft Form

    A snapshot of this data is taken in script 2 and written to ADM in the table `contacts_new`.

3.  Historic contact data collected via a Google form

    This data is stored in the ADM table `contacts_old`.
    
Scripts 3 and 4 use these data sources to produce an analysis table, stored in ADM as `analysis`.


## Config

To run the process, you need to create a `config.yml` file. 
This file isn't tracked by git, however the expected format can be seen in `config-example.yml`.

The following parameters are required:

* `adm_server`: The value passed to the `server` argument of `RtoSQLServer::write_dataframe_to_db`.

* `ms_form_link`: The URL of the Excel spreadsheet of form responses in OneDrive online.

* `ms_form_path`: The file path to where the Excel spreadsheet of form responses is stored locally.
If you are not the owner of the Microsoft Form and are unable to access this via File Explorer, 
you will have to download a copy of the shared file from OneDrive online. 
The file path should then be to where you have stored this downloaded copy.


## Process

1.  Create `config.yml` file. 

2.  Run the scripts in the `scripts/` folder one by one in their numbered order.


## Output

These are stored in the `outputs/` folder.

1.  An Excel spreadsheet containing all available data, split by organisation.

    * Script 5 produces this file containing information for all organisations. 
    To produce this file for one organisation only, use the `excel_output()` function and
    specify the `org_group` argument.

2. A Quarto dashboard containing a more user-friendly summary and detailed breakdown of apps.

Any additional analysis should be carried out using the `analysis` table on ADM.


## R Package

The functions defined in the `R/` folder are used to form an R package, `shinyadmin`.


## Contact

This repository is maintained by the [Data Innovation team](mailto:alice.hannah@gov.scot;thomas.wilson@gov.scot).


## Licence

Unless stated otherwise, the codebase is released under [the MIT License](LICENCE). This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright](http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government 3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
