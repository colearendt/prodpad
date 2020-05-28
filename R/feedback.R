#' @export
feedback <- function(client, contact, feedback, tags = NULL, personas = NULL, products = NULL, source = NULL, links = NULL) {

  stopifnot(length(contact) == 1)
  stopifnot(length(source) == 1)

  if (is.numeric(contact)) {
    # this is a contact ID
    contact_param <- list(contact_id = contact)
  } else {
    # maybe it's a name...? try to create it?
    contact_param <- list(name = contact)
  }

  tags_param <- purrr::map(as.list(tags), ~ list(id = .x))
  personas_param <- purrr::map(as.list(personas), ~ list(id = .x))
  products_param <- purrr::map(as.list(products), ~ list(id = .x))
  links_param <- purrr::map(as.list(links), ~ list(name = .x, url = .x))

  post_body <- c(
    contact_param,
    list(
      feedback = feedback,
      tags = tags_param,
      personas = personas_param,
      products = products_param,
      links = links_param,
      source = source
    )
  )

  str(post_body)

  client$POST()
}
