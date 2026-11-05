#' Test a peak for an unresolved shoulder
#'
#' @param y Numeric vector; smoothed, baseline-corrected signal.
#' @param rt Numeric vector of times, same length as `y`.
#' @param apex,start,end Integer indices of the peak apex and bounds in `y`.
#' @param depth_frac Numeric; a second-derivative minimum must reach this
#'   fraction of the deepest minimum in the peak to count.
#' @param width_frac Numeric; second-derivative filter length as a fraction of
#'   the peak width in points (adapts to peak width and sampling rate).
#'
#' @return Logical; `TRUE` if the second derivative has a minimum within the
#'   peak that is not explained by the apex.
#'
#' @keywords internal
.has_shoulder <- function(
  y,
  rt,
  apex,
  start,
  end,
  depth_frac = 0.2,
  width_frac = 0.12
) {
  n <- end - start + 1L
  w <- 2L * floor(n * width_frac / 2) + 1L
  if (w < 5L) {
    return(FALSE)
  }
  ctx <- max(1L, start - n):min(length(y), end + n)
  if (length(ctx) < w) {
    return(FALSE)
  }
  d2 <- .derivative_signal(y[ctx], rt[ctx], 2, window = w)
  d2 <- d2[(start - ctx[1] + 1L):(end - ctx[1] + 1L)]
  tol <- max(3L, round(0.1 * n))
  sh <- .find_shoulders(
    d2,
    apex - start + 1L,
    min_depth = depth_frac * abs(min(d2)),
    tol = tol
  )
  length(sh) > 0L
}
