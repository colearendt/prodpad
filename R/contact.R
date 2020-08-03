

#' @export
pp_create_contact <- function(client, name) {
  res <- client$POST("/contacts", body = list(
    name = name
  ))

  return(res)
}
