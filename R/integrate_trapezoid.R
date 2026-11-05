#' Trapezoidal integral
#'
#' @param x,y Numeric vectors of equal length; `x` ascending, not necessarily
#'   evenly spaced. Pairs with a missing value are dropped.
#' @param call Call environment for errors.
#'
#' @return Numeric scalar; 0 when fewer than two usable points remain.
#'
#' @keywords internal
.integrate_trapezoid <- function(x, y, call = rlang::caller_env()) {
  if (length(x) != length(y)) {
    .moosaic_abort(
      "{.arg x} and {.arg y} must have the same length.",
      class = "bad_argument",
      call = call
    )
  }
  ok <- !is.na(x) & !is.na(y)
  x <- x[ok]
  y <- y[ok]
  if (length(x) < 2L) {
    return(0)
  }
  sum(diff(x) * (utils::head(y, -1L) + utils::tail(y, -1L)) / 2)
}
