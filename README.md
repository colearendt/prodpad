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

## Scripted Feedback

If you want to script your feedback entry, you can do so like this:

```r
library(prodpad)
pcli <- prodpad()

all_tags <- get_tags_vector(pcli)
all_contacts <- get_contacts_vector(pcli)
all_personas <- get_personas_vector(pcli)
all_products <- get_products_vector(pcli)

# submit feedback
feedback(
  pcli, 
  contact = all_contacts$`Anonymous Feedback`, 
  tags = c(all_tags$`IT Adoption`), 
  personas = all_personas$`IT Administrator`, 
  products = c(all_products$`RStudio Connect`, all_products$`RStudio Pro`), 
  source = feedback_sources$email,
  feedback = "This is some feedback that I created"
  )

# go look at it in the browser
browseURL(feedback_url(submitted$feedbacks$id))
```

## A Shiny App

This app is still very much a WIP. However, if you run the following in the project directory, you will get a Shiny app that should help you submit feedback!
```
shiny::runApp("submit_feedback_app/app.R")
```

## Notes

- Ideas cannot be tied to products after the fact due to what feels very much
like a deficient data model
    - Rather, you need to filter by "product" in the `get_ideas()` function
    - i.e. `get_ideas(pcli, "My Product")`
- Right now, ProdPad does not have paging limits, so we avoid paging by setting
`limit = large`. This will probably change at some point to provide more
flexibility
