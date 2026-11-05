#' Topographic prominence of peaks
#'
#' @param x Numeric vector.
#' @param idx Integer vector; indices of local maxima in `x`.
#'
#' @return Numeric vector, one value per `idx`: the height of the peak above
#'   the higher of its two bases. Each base is the lowest point reached
#'   walking away from the peak until a higher point (or the end of `x`) is
#'   met.
#'
#' @keywords internal
.peak_prominence <- function(x, idx) {
  n <- length(x)
  vapply(
    idx,
    \(i) {
      lmin <- x[i]
      j <- i - 1L
      while (j >= 1L && x[j] <= x[i]) {
        lmin <- min(lmin, x[j])
        j <- j - 1L
      }
      rmin <- x[i]
      j <- i + 1L
      while (j <= n && x[j] <= x[i]) {
        rmin <- min(rmin, x[j])
        j <- j + 1L
      }
      x[i] - max(lmin, rmin)
    },
    numeric(1)
  )
}
