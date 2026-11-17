#' Peak sigma from the full width at half maximum
#'
#' @param y Numeric vector; smoothed, baseline-corrected signal.
#' @param apex,start,end Integer indices of the peak apex and bounds in `y`.
#'
#' @return Numeric; Gaussian-equivalent sigma in points (FWHM / 2.355), at
#'   least 1. When the signal does not fall to half height within the bounds,
#'   the bound is used for that side.
#'
#' @keywords internal
.half_width_sigma <- function(y, apex, start, end) {
  half <- y[apex] / 2
  left <- apex - start
  below_l <- which(y[apex:start] < half)
  if (length(below_l) > 0L) {
    left <- below_l[1] - 1L
  }
  right <- end - apex
  below_r <- which(y[apex:end] < half)
  if (length(below_r) > 0L) {
    right <- below_r[1] - 1L
  }
  max(1, (left + right) / 2.355)
}
