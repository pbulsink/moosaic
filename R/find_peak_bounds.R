#' Find peak boundaries around an apex
#'
#' @param x Numeric vector (baseline-corrected, smoothed).
#' @param apex_idx Integer; index of the apex.
#' @param floor Numeric; stop once the signal reaches this level.
#' @param tol Numeric; noise tolerance. A side stops when the signal climbs
#'   more than `tol` above the lowest point seen so far on that side, so small
#'   noise bumps do not end the walk early.
#'
#' @return Named integer vector `c(start, end)`. Each side walks downhill and
#'   stops at the lowest point before a rise of more than `tol` (a valley), at
#'   the first point at or below `floor`, or at the end of the vector.
#'
#' @keywords internal
.find_peak_bounds <- function(x, apex_idx, floor = 0, tol = 0) {
  walk <- function(step) {
    n <- length(x)
    best <- apex_idx
    i <- apex_idx
    repeat {
      i <- i + step
      if (i < 1L || i > n) {
        break
      }
      if (x[i] <= floor) {
        best <- i
        break
      }
      if (x[i] < x[best]) {
        best <- i
      } else if (x[i] > x[best] + tol) {
        break
      }
    }
    best
  }
  c(start = walk(-1L), end = walk(1L))
}
