#' Inform with moosaic message
#'
#' Internal helper to issue structured cli informational messages.
#'
#' @param message Character; informational message.
#' @param class Character; optional message class suffix (becomes
#'   `moosaic-message-{class}`).
#' @param .envir Environment used to evaluate `{}` expressions in `message`.
#'
#' @keywords internal
.moosaic_inform <- function(
  message,
  class = NULL,
  .envir = rlang::caller_env()
) {
  classes <- "moosaic-message"
  if (!is.null(class)) {
    classes <- c(classes, paste0("moosaic-message-", class))
  }
  cli::cli_inform(message, class = classes, .envir = .envir)
}
