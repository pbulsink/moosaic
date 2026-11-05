#' Find shoulders from a second derivative
#'
#' @param d2 Numeric vector; second derivative of a peak region.
#' @param apex_idx Integer vector; indices of known apexes in `d2`.
#' @param min_depth Numeric; a minimum of `d2` must be at or below
#'   `-min_depth` to count.
#' @param tol Integer; minima within `tol` points of an apex belong to that
#'   apex and are not shoulders.
#'
#' @return Integer vector of indices of negative local minima of `d2` that are
#'   not explained by an apex. Each is an unresolved overlapping component.
#'
#' @keywords internal
.find_shoulders <- function(d2, apex_idx = integer(), min_depth = 0, tol = 2L) {
  n <- length(d2)
  if (n < 3L) {
    return(integer())
  }
  i <- 2:(n - 1L)
  mins <- i[
    d2[i] < d2[i - 1L] & d2[i] <= d2[i + 1L] & d2[i] < 0 & d2[i] <= -min_depth
  ]
  if (length(apex_idx) == 0L || length(mins) == 0L) {
    return(mins)
  }
  near <- vapply(mins, \(m) any(abs(m - apex_idx) <= tol), logical(1))
  mins[!near]
}
