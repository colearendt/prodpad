#' @export
ProdPad <- R6::R6Class(
  "ProdPad",
  public = list(
    url = NULL,
    api_key = NULL,
    initialize = function(api_key, url = "https://api.prodpad.com/v1") {
      self$api_key = api_key
      self$url = base::sub("^(.*)/$", "\\1", url)
    },

    GET = function(path, writer = httr::write_memory(), parser = 'parsed') {
      req <- paste0(self$url, path)
      res <- httr::GET(
        req,
        self$add_auth(),
        writer
        )
      self$raise_error(res)
      check_debug(req, res)
      httr::content(res, as = parser)
    },

    search = function(query, type = c("ideas", "products", "personas", "feedbacks")) {
      query_encoded <- utils::URLencode(paste(query, collapse = "&"))
      self$GET(glue::glue("/search?q={query}"))
    },

    add_auth = function() {
      httr::add_headers(Authorization = paste0('Bearer ', self$api_key))
    },

    raise_error = function(res) {
      if (httr::http_error(res)) {
        err <- sprintf('%s request failed with %s',
                       res$request$url,
                       httr::http_status(res)$message)
        message(capture.output(str(httr::content(res))))
        stop(err)
      }
    }
  )
)

#' @export
prodpad_api_docs <- function() {
  utils::browseURL("https://app.swaggerhub.com/apis-docs/ProdPad/prodpad/1.0#/")
}

#' @export
prodpad_api_key <- function() {
  utils::browseURL("https://app.prodpad.com/me/apikeys")
}

#' @export
prodpad <- function(
  api_key = Sys.getenv("PRODPAD_API_KEY", NA_character_),
  url = Sys.getenv("PRODPAD_URL", "https://api.prodpad.com/v1")
) {
  client <- ProdPad$new(api_key = api_key, url = url)

  client
}

check_debug <- function(req, res) {
  debug <- getOption('prodpad.debug')
  if (!is.null(debug) && debug) {
    message(req)
    message(httr::content(res, as = 'text'))
  }
}

