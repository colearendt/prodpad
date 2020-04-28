# prodpad

<!-- badges: start -->
<!-- badges: end -->

The goal of prodpad is to make submitting and reviewing feedback simple, thereby
increasing feedback quality and simplifying the arc for utilizing that feedback.

## Installation

You can install the released version of prodpad from
[GitHub](https://github.com/colearendt/prodpad) with:

``` r
remotes::install_github("prodpad")
```

## Example

To get started, you need a ProdPad API key. This can be found by going to:
[Profile => API Keys](https://app.prodpad.com/me/apikeys). (Or use
`prodpad_api_key()` to navigate there interactively)

Then export that API key as an environment variable (i.e. in `.Renviron`):
```
PRODPAD_API_KEY=my-api-key
```

Then either restart your R session or `readRenviron(".Renviron")`

``` r
library(prodpad)

pcli <- prodpad()

get_feedback(pcli)
get_tags(pcli)
get_companies(pcli)
get_contacts(pcli)
get_ideas(pcli)
get_personas(pcli)
get_product(pcli)

prodpad_api_docs()
```

## Notes

- Ideas cannot be tied to products after the fact due to what feels very much
like a deficient data model
    - Rather, you need to filter by "product" in the `get_ideas()` function
    - i.e. `get_ideas(pcli, "My Product")`
- Right now, ProdPad does not have paging limits, so we avoid paging by setting
`limit = large`. This will probably change at some point to provide more
flexibility
