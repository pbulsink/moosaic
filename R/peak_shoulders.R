#' Locate unresolved shoulders within a peak
#'
#' @param y Numeric vector; smoothed, baseline-corrected signal.
#' @param rt Numeric vector of times, same length as `y`.
#' @param apex,start,end Integer indices of the peak apex and bounds in `y`.
#' @param depth_frac Numeric; a second-derivative dip must have a prominence
#'   of at least this fraction of the apex's second-derivative depth.
#' @param width_frac Numeric; second-derivative filter length as a fraction of
#'   the peak width in points (adapts to peak width and sampling rate).
#' @param noise Numeric; white-noise SD of the unsmoothed signal. The dip
#'   prominence must also reach a sliding multiple of the noise propagated
#'   through the second-derivative filter (see Details). `0` disables the
#'   noise gate.
#' @param noise_k Numeric length 2; noise multiples at the apex and on the
#'   flank (from `slide_sigma` peak sigmas outward).
#' @param slide_sigma Numeric; distance from the apex, in peak sigmas, over
#'   which the multiple falls linearly from `noise_k[1]` to `noise_k[2]`.
#' @param min_height Numeric; minimum signal height at a shoulder.
#'
#' @return Integer vector (possibly empty, sorted) of indices into `y` of
#'   second-derivative dips inside the peak that are not explained by the
#'   apex. Each marks an unresolved overlapping component.
#'
#' @details A dip is a local minimum of the second derivative, measured by its
#'   prominence (depth below the lower flanking maximum) rather than by its
#'   sign, so a small component on the flank of a larger peak, where the
#'   second derivative is positive, is still found. On synthetic Gaussians at
#'   moderate noise, a 10% component 3 sigma from the apex is reliably found;
#'   5% components, or components 2.5 sigma or less away, generally are not:
#'   their dips are no larger than noise dips.
#'
#'   The noise gate slides with distance from the apex. Peak sigma is
#'   estimated from the full width at half maximum (FWHM / 2.355) of `y`. A dip
#'   `d` sigmas from the apex must reach
#'   `k(d) = noise_k[1] + (noise_k[2] - noise_k[1]) * min(d / slide_sigma, 1)`
#'   times the second-derivative noise. Ragged or flat tops near the apex are
#'   held to a stricter standard than flank shoulders, where real minor
#'   components appear.
#'
#' @keywords internal
.peak_shoulders <- function(
  y,
  rt,
  apex,
  start,
  end,
  depth_frac = 0.02,
  width_frac = 0.18,
  noise = 0,
  noise_k = c(10, 5),
  slide_sigma = 3,
  min_height = 0
) {
  n <- end - start + 1L
  w <- 2L * floor(n * width_frac / 2) + 1L
  if (w < 5L) {
    return(integer())
  }
  ctx <- max(1L, start - n):min(length(y), end + n)
  if (length(ctx) < w) {
    return(integer())
  }
  d2 <- .derivative_signal(y[ctx], rt[ctx], 2, window = w)
  d2 <- d2[(start - ctx[1] + 1L):(end - ctx[1] + 1L)]
  tol <- max(3L, round(0.1 * n))
  dt <- (rt[ctx[length(ctx)]] - rt[ctx[1]]) / (length(ctx) - 1)
  # Raw-noise propagation overstates d2 noise on smoothed y: conservative
  d2_noise <- noise * sqrt(sum(.sg_coefs(w, 3L, 2L)^2)) / dt^2
  sh <- .find_shoulders(
    d2,
    apex - start + 1L,
    min_prominence = depth_frac * abs(min(d2)),
    tol = tol
  )
  if (length(sh) > 0L && noise > 0) {
    sigma <- .half_width_sigma(y, apex, start, end)
    dist <- abs(sh + start - 1L - apex) / sigma
    k <- noise_k[1] + (noise_k[2] - noise_k[1]) * pmin(dist / slide_sigma, 1)
    sh <- sh[.peak_prominence(-d2, sh) >= k * d2_noise]
  }
  sh <- sh + start - 1L
  as.integer(sort(sh[y[sh] >= min_height]))
}
