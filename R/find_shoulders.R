#' Find shoulders from a second derivative
#'
#' @param d2 Numeric vector; second derivative of a peak region.
#' @param apex_idx Integer vector; indices of known apexes in `d2`.
#' @param min_prominence Numeric; a local minimum of `d2` counts when it dips
#'   at least this far below the lower of its two flanking maxima (the
#'   topographic prominence of `-d2`). The minimum need not be negative, so a
#'   minor component riding on the convex flank of a larger peak is found.
#' @param tol Integer; minima within `tol` points of an apex belong to that
#'   apex and are not shoulders.
#'
#' @return Integer vector of indices of local minima of `d2` that are
#'   prominent enough and not explained by an apex. Each is an unresolved
#'   overlapping component.
#'
#' @keywords internal
.find_shoulders <- function(
  d2,
  apex_idx = integer(),
  min_prominence = 0,
  tol = 2L
) {
  n <- length(d2)
  if (n < 3L) {
    return(integer())
  }
  i <- 2:(n - 1L)
  mins <- i[d2[i] < d2[i - 1L] & d2[i] <= d2[i + 1L]]
  mins <- mins[.peak_prominence(-d2, mins) >= min_prominence]
  if (length(apex_idx) == 0L || length(mins) == 0L) {
    return(mins)
  }
  near <- vapply(mins, \(m) any(abs(m - apex_idx) <= tol), logical(1))
  mins[!near]
}
