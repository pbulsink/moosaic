#' Check that a result has been quantified
#'
#' @param result Object to check.
#' @param call Call environment for errors.
#'
#' @return `result`, invisibly. Aborts with class `bad_argument` if it is not
#'   a `moosaic_result`, or `not_quantified` if [quantify()] has not been run.
#'
#' @keywords internal
.require_quantified <- function(result, call = rlang::caller_env()) {
  if (!inherits(result, "moosaic_result")) {
    .moosaic_abort(
      "{.arg result} must be a {.cls moosaic_result}.",
      class = "bad_argument",
      call = call
    )
  }
  if (is.null(result$peaks) || is.null(result$quant)) {
    .moosaic_abort(
      "{.arg result} has not been quantified; run {.fn quantify} first.",
      class = "not_quantified",
      call = call
    )
  }
  invisible(result)
}
