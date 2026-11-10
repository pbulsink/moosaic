#' Set moosaic options
#'
#' Set one or more moosaic options, with validation.
#'
#' @param ... Named arguments, one per option (without `moosaic.` prefix).
#'
#' @return Invisibly, the previous values of the set options.
#'
#' @examples
#' old <- set_moosaic_options(rank_max = 8L)
#' old
#'
#' @export
set_moosaic_options <- function(...) {
  dots <- list(...)

  # Early return if no options
  if (length(dots) == 0) {
    return(invisible(list()))
  }

  defaults <- .moosaic_default_options()

  # Validate all names
  for (name in names(dots)) {
    full_name <- paste0("moosaic.", name)
    if (!full_name %in% names(defaults)) {
      .moosaic_abort(
        paste("unknown option", full_name),
        class = "unknown_option",
        call = rlang::caller_env()
      )
    }
  }

  # Build options list with full names
  opts_to_set <- stats::setNames(dots, paste0("moosaic.", names(dots)))
  old <- options(opts_to_set)

  invisible(old)
}
