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
[Profile => API Keys](https://app.prodpad.com/me/apikeys).

Then export that API key as an environment variable (i.e. in `.Renviron`):
```
PRODPAD_API_KEY=my-api-key
```

Then either restart your R session or `readRenviron(".Renviron")`

``` r
library(prodpad)

pcli <- prodpad()

get_feedback(pcli)
```
