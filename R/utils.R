safe_query <- function(expr, prefix = "", collapse = "|") {
  if (is.null(expr)) {
    return("")
  } else if (identical(expr, TRUE)) {
    return(paste0(prefix, "true"))
  } else if (identical(expr, FALSE)) {
    return(paste0(prefix, "false"))
  } else {
    return(paste0(prefix, glue::glue_collapse(expr, sep = collapse)))
  }
}
