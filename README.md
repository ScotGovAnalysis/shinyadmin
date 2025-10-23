# Shiny Server Analysis

The code in this repository is used to assist with administration of the Scottish Public Sector [shinyapps.io](https://www.shinyapps.io/) account (scotland.shinyapps.io). 

## Prerequisites

1. You must be a member of the `scotland` shinyapps.io account.

2. You must have registered the `scotland` account in RStudio using an account token and secret. This can be done using the following code:

    ```
    rsconnect::setAccountInfo(
      name   = "scotland",
      token  = "",
      secret = ""
    )
    ```

## Data

## Process

1.  Create `config.yml` file. 
 
    This file isn't tracked by git, however the expected format can be seen in `config-example.yml`.

## Output

## Contact

This repository is maintained by the [Data Innovation team](mailto:alice.hannah@gov.scot;thomas.wilson@gov.scot).

## Licence

[MIT License](LICENCE)
