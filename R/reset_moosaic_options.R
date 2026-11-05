#' Reset moosaic options to defaults
#'
#' Restores all moosaic options to their default values.
#'
#' @return Invisibly, the previous values.
#'
#' @examples
#' reset_moosaic_options()
#'
#' @export
reset_moosaic_options <- function() {
  defaults <- .moosaic_default_options()
  old <- options(defaults)
  invisible(old)
}
