#' Robust noise estimate
#'
#' @param x Numeric vector.
#'
#' @return Single number: the standard deviation of white noise implied by the
#'   median absolute deviation of first differences. Insensitive to peaks and
#'   slow drift.
#'
#' @keywords internal
.estimate_noise <- function(x) {
  stats::mad(diff(x)) / sqrt(2)
}
