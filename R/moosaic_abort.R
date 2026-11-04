#' Abort with moosaic error
#'
#' Internal helper to issue structured cli errors with moosaic-specific classes.
#'
#' @param message Character; error message. Use `{.fn}` to name the calling function.
#' @param class Character; error class suffix (becomes `moosaic-error-{class}`).
#' @param call Call environment for error location (usually `rlang::caller_env()`).
#'
#' @return Does not return (aborts).
#'
#' @keywords internal
#' @examples
#' \dontrun{
#'   .moosaic_abort("unknown option", "unknown_option", call = rlang::caller_env())
#' }
.moosaic_abort <- function(message, class = NULL, call = rlang::caller_env()) {
  classes <- "moosaic-error"
  if (!is.null(class)) {
    classes <- c(classes, paste0("moosaic-error-", class))
  }
  rlang::abort(message, class = classes, call = call)
}

#' Warn with moosaic warning
#'
#' Internal helper to issue structured cli warnings with moosaic-specific classes.
#'
#' @param message Character; warning message.
#' @param class Character; warning class suffix (becomes `moosaic-warning-{class}`).
#' @param call Call environment for warning location.
#'
#' @keywords internal
.moosaic_warn <- function(message, class = NULL, call = rlang::caller_env()) {
  classes <- "moosaic-warning"
  if (!is.null(class)) {
    classes <- c(classes, paste0("moosaic-warning-", class))
  }
  cli::cli_warn(message, class = classes, call = call)
}

#' Inform with moosaic message
#'
#' Internal helper to issue structured cli informational messages.
#'
#' @param message Character; informational message.
#' @param class Character; optional message class suffix.
#'
#' @keywords internal
.moosaic_inform <- function(message, class = NULL) {
  cli::cli_inform(message)
}
