#' Extract metadata from a raw data object
#'
#' Pulls attributes into a named list, excluding structural metadata like `dim`.
#'
#' @param x An object with attributes.
#'
#' @return Named list of attributes (excluding `dim`, `dimnames`, `class`).
#'
#' @keywords internal
.extract_metadata <- function(x) {
  atts <- attributes(x)
  exclude <- c("dim", "dimnames", "class", "names")
  keep <- setdiff(names(atts), exclude)
  as.list(atts[keep])
}
