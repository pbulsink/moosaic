#' Find local maxima
#'
#' @param x Numeric vector.
#' @param min_height Numeric; minimum value for a maximum to be reported.
#'
#' @return Integer vector of indices where `x` rises into a point and does not
#'   rise beyond it (the first point of a flat top). End points are never
#'   reported.
#'
#' @keywords internal
.find_local_maxima <- function(x, min_height = -Inf) {
  n <- length(x)
  if (n < 3L) {
    return(integer())
  }
  i <- 2:(n - 1L)
  hit <- x[i] > x[i - 1L] & x[i] >= x[i + 1L] & x[i] >= min_height
  i[hit]
}
