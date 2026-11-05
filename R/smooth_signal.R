#' Savitzky-Golay smoothing
#'
#' @param x Numeric vector.
#' @param window Odd integer; filter length in points (at least 3, at most
#'   `length(x)`).
#' @param order Integer; polynomial order.
#' @param call Call environment for errors.
#'
#' @return Numeric vector, same length as `x`. Edges are handled by repeating
#'   the end values.
#'
#' @keywords internal
.smooth_signal <- function(x, window, order = 3L, call = rlang::caller_env()) {
  coefs <- .sg_coefs(window, order, 0L, call = call)
  if (length(x) < window) {
    .moosaic_abort(
      "{.arg x} (length {length(x)}) is shorter than {.arg window} ({window}).",
      class = "bad_window",
      call = call
    )
  }
  .apply_filter(x, coefs)
}
