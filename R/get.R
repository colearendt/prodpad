
#' @export
get_feedback <- function(client) {
  rawdat <- client$GET("/feedback?size=10000")

  wider <- tidyr::unnest_wider(
    tibble::tibble(dat = rawdat), dat)

  tidyr::unnest_wider(wider, added_by, sep = "_")
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
get_ideas <- function(client) {
  rawdat <- client$GET("/ideas?size=10000")

  tidyr::unnest_wider(tibble::tibble(dat = rawdat$ideas), dat)
}
