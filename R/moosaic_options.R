#' Get all moosaic options
#'
#' Returns a list of currently set moosaic options.
#'
#' @return Named list of moosaic options (those starting with `moosaic.`).
#'
#' @examples
#' moosaic_options()
#'
#' @export
moosaic_options <- function() {
  opts <- options()
  moosaic_opts <- opts[startsWith(names(opts), "moosaic.")]
  moosaic_opts
}
