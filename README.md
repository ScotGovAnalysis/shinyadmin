# shinyadmin

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

Unless stated otherwise, the codebase is released under [the MIT License](LICENCE). This covers both the codebase and any sample code in the documentation.

The documentation is [© Crown copyright](http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government 3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
