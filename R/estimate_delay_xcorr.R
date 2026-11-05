#' Estimate detector delay by cross-correlation
#'
#' @param fid,tic Lists with numeric `rt` and `intensity` (min).
#' @param max_delay Numeric; largest delay magnitude searched (min).
#' @param step Numeric; common grid spacing (min).
#'
#' @return A list with `delay` (min; positive when MS times are later than
#'   FID times) and `score` (normalised correlation at the best lag).
#'
#' @details Both traces are linearly interpolated onto a common grid over
#'   their overlapping range, baseline-corrected and cross-correlated over
#'   lags within `max_delay`. The peak is refined by a parabola through the
#'   best lag and its neighbours.
#'
#' @keywords internal
.estimate_delay_xcorr <- function(fid, tic, max_delay, step) {
  lo <- max(min(fid$rt), min(tic$rt))
  hi <- min(max(fid$rt), max(tic$rt))
  grid <- seq(lo, hi, by = step)
  f <- .correct_baseline(stats::approx(fid$rt, fid$intensity, grid)$y)
  g <- .correct_baseline(stats::approx(tic$rt, tic$intensity, grid)$y)
  n <- length(grid)
  K <- min(floor(max_delay / step), n %/% 2L)
  lags <- -K:K
  cc <- vapply(
    lags,
    \(k) {
      if (k >= 0) {
        a <- f[seq_len(n - k)]
        b <- g[(1 + k):n]
      } else {
        a <- f[(1 - k):n]
        b <- g[seq_len(n + k)]
      }
      d <- sqrt(sum(a^2) * sum(b^2))
      if (d == 0) 0 else sum(a * b) / d
    },
    numeric(1)
  )
  i <- which.max(cc)
  offset <- 0
  if (i > 1L && i < length(cc)) {
    den <- cc[i - 1L] - 2 * cc[i] + cc[i + 1L]
    if (den < 0) {
      offset <- 0.5 * (cc[i - 1L] - cc[i + 1L]) / den
    }
  }
  list(delay = (lags[i] + offset) * step, score = cc[i])
}
