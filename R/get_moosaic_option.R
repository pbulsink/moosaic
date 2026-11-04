#' Get a moosaic option by name
#'
#' Internal helper to read a moosaic option, with validation.
#'
#' @param name Character; option name (without `moosaic.` prefix).
#' @param call Call environment for errors.
#'
#' @return The option value, or aborts if unknown.
#'
#' @keywords internal
.get_moosaic_option <- function(name, call = rlang::caller_env()) {
  full_name <- paste0("moosaic.", name)
  defaults <- .moosaic_default_options()

  if (!full_name %in% names(defaults)) {
    .moosaic_abort(
      paste("unknown option", full_name),
      class = "unknown_option",
      call = call
    )
  }

  getOption(full_name)
}
