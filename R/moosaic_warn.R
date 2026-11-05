#' Warn with moosaic warning
#'
#' Internal helper to issue structured cli warnings with moosaic-specific classes.
#'
#' @param message Character; warning message.
#' @param class Character; warning class suffix (becomes `moosaic-warning-{class}`).
#' @param call Call environment for warning location.
#' @param .envir Environment used to evaluate `{}` expressions in `message`.
#'
#' @keywords internal
.moosaic_warn <- function(
  message,
  class = NULL,
  call = rlang::caller_env(),
  .envir = rlang::caller_env()
) {
  classes <- "moosaic-warning"
  if (!is.null(class)) {
    classes <- c(classes, paste0("moosaic-warning-", class))
  }
  cli::cli_warn(message, class = classes, call = call, .envir = .envir)
}
