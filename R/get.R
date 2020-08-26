
expand_response <- function(client, url, filter = .x) {
  rawdat<- client$GET(url)

  filter_expr <- rlang::enquo(filter)

  tidyr::unnest_wider(tibble::tibble(dat = rlang::eval_tidy(expr = filter_expr, data = list(.x = rawdat))), dat)
}

#' @export
get_feedback <- function(client, product = NULL, tags = NULL) {
  url <- glue::glue(
    "/feedbacks?size=10000",
    safe_query(product, prefix="product="),
    safe_query(tags, prefix="tags="),
    .sep = "&"
  )
  rawdat <- client$GET(url)

  wider <- tidyr::unnest_wider(
    tibble::tibble(dat = rawdat), dat)

  tidyr::unnest_wider(wider, added_by, names_sep = "_")
}

#' @export
get_tags <- function(client) {
  rawdat <- client$GET("/tags?size=10000")

  tidyr::unnest_wider(tibble::tibble(dat = rawdat), dat)
}

#' @export
get_companies <- function(client, .limit = 10) {
  dat_agg <- list()
  page_num <- 1
  res <- client$GET(glue::glue("/companies?page={page_num}"))
  dat_agg <- c(dat_agg, res$companies)
  while (res$n != 0 && page_num <= .limit) {
    page_num <- page_num + 1
    res <- NULL

    res <- client$GET(glue::glue("/companies?page={page_num}"))
    dat_agg <- c(dat_agg, res$companies)
  }

  tidyr::unnest_wider(tibble::tibble(dat = dat_agg), dat)
}

#' @export
get_contacts <- function(client) {
  rawdat <- client$GET("/contacts?size=10000")

  tidyr::unnest_wider(tibble::tibble(dat = rawdat$contacts), dat)
}

#' @export
get_ideas <- function(client, product = NULL) {
  url <- glue::glue(
    "/ideas?size=10000",
    safe_query(product, prefix="product="),
    .sep = "&"
  )
  rawdat <- client$GET(url)

  tidyr::unnest_wider(tibble::tibble(dat = rawdat$ideas), dat)
}

#' @export
get_idea <- function(client, id) {
  url <- glue::glue("/ideas/", as.character(id))
  rawdat <- client$GET(url)
}

#' @export
get_personas <- function(client) {
  rawdat <- client$GET("/personas")

  tidyr::unnest_wider(tibble::tibble(dat=rawdat), dat)
}

#' @export
get_products <- function(client) {
  rawdat <- client$GET("/products")

  tidyr::unnest_wider(tibble::tibble(dat=rawdat), dat)
}

#' @export
feedback_sources <- c(
  "email", "conference", "in_person_conversation", "sales_team", "social_media", "telephone_conversation", "user_test", "website_contact_form", "customer_feedback_portal", "customer_feedback_widget", "api"
)
