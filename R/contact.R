

#' @export
pp_create_contact <- function(client, name) {
  res <- client$POST("/contacts", body = list(
    name = name
  ))

  return(res)
}

#' @export
pp_contact_url <- function(id) {
  glue::glue("https://app.prodpad.com/contacts/{id}/about")
}
