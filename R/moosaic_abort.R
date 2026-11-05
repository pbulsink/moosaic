#' Abort with moosaic error
#'
#' Internal helper to issue structured cli errors with moosaic-specific classes.
#'
#' @param message Character; error message. Use `{.fn}` to name the calling function.
#' @param class Character; error class suffix (becomes `moosaic-error-{class}`).
#' @param call Call environment for error location (usually `rlang::caller_env()`).
#' @param .envir Environment used to evaluate `{}` expressions in `message`.
#'
#' @return Does not return (aborts).
#'
#' @keywords internal
#' @examples
#' \dontrun{
#'   .moosaic_abort("unknown option", "unknown_option", call = rlang::caller_env())
#' }
.moosaic_abort <- function(
  message,
  class = NULL,
  call = rlang::caller_env(),
  .envir = rlang::caller_env()
) {
  classes <- "moosaic-error"
  if (!is.null(class)) {
    classes <- c(classes, paste0("moosaic-error-", class))
  }
  cli::cli_abort(message, class = classes, call = call, .envir = .envir)
}
