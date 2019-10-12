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
      res <- httr::GET(req, writer)
      self$raise_error(res)
      check_debug(req, res)
      httr::content(res, as = parser)
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

check_debug <- function(req, res) {
  debug <- getOption('prodpad.debug')
  if (!is.null(debug) && debug) {
    message(req)
    message(httr::content(res, as = 'text'))
  }
}
