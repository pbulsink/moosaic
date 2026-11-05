#' Savitzky-Golay derivative of a signal
#'
#' @param x Numeric vector.
#' @param rt Numeric vector of x positions (min), same length as `x`, evenly
#'   spaced.
#' @param order Integer; derivative order (1 or 2).
#' @param window Odd integer; filter length in points.
#' @param poly_order Integer; local polynomial order (at least `order`).
#' @param call Call environment for errors.
#'
#' @return Numeric vector, same length as `x`, in units of `x` per `rt^order`.
#'   Values within half a window of either end are less reliable.
#'
#' @keywords internal
.derivative_signal <- function(
  x,
  rt,
  order = 1L,
  window = 7L,
  poly_order = max(3L, order),
  call = rlang::caller_env()
) {
  if (length(rt) != length(x)) {
    .moosaic_abort(
      "{.arg rt} and {.arg x} must be the same length.",
      class = "bad_argument",
      call = call
    )
  }
  if (length(x) < window) {
    .moosaic_abort(
      "{.arg x} (length {length(x)}) is shorter than {.arg window} ({window}).",
      class = "bad_window",
      call = call
    )
  }
  coefs <- .sg_coefs(window, poly_order, order, call = call)
  dt <- (rt[length(rt)] - rt[1]) / (length(rt) - 1)
  .apply_filter(x, coefs) / dt^order
}
