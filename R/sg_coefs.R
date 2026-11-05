#' Savitzky-Golay filter coefficients
#'
#' @param window Odd integer; filter length in points.
#' @param order Integer; polynomial order, must be less than `window`.
#' @param deriv Integer; derivative order (0 = smoothing), at most `order`.
#' @param call Call environment for errors.
#'
#' @return Numeric vector of length `window`, ordered for use with
#'   [stats::filter()] (convolution). For `deriv > 0` the result is per unit
#'   point spacing; divide by `dt^deriv` to obtain derivatives per unit of x.
#'
#' @keywords internal
.sg_coefs <- function(
  window,
  order = 3L,
  deriv = 0L,
  call = rlang::caller_env()
) {
  if (
    !is.numeric(window) ||
      length(window) != 1L ||
      is.na(window) ||
      window < 3 ||
      window %% 2 != 1
  ) {
    .moosaic_abort(
      "{.arg window} must be an odd integer of at least 3.",
      class = "bad_window",
      call = call
    )
  }
  if (order >= window || deriv > order) {
    .moosaic_abort(
      "{.arg order} must be less than {.arg window} and at least {.arg deriv}.",
      class = "bad_argument",
      call = call
    )
  }
  h <- (window - 1) / 2
  t <- seq(-h, h)
  A <- outer(t, 0:order, `^`)
  pinv <- solve(crossprod(A), t(A))
  rev(factorial(deriv) * pinv[deriv + 1, ])
}
