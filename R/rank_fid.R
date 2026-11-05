#' Rank estimate from the FID trace
#'
#' @param fid List with numeric `rt` and `intensity` of equal length: the FID
#'   resampled onto the window's scans (see `.extract_fid_window()`).
#' @param call Call environment for errors.
#'
#' @return Integer; the number of distinct peaks, or `NA` when fewer than 5
#'   non-missing points are available. 0 for a flat, monotone or noise-only
#'   trace.
#'
#' @details Missing values are filled by linear interpolation. A local maximum
#'   counts when its prominence is at least `moosaic.peak_min_height_snr`
#'   times the noise and at least 5% of the trace range. Noise comes from
#'   third differences, which remove smooth peak structure. Unresolved
#'   shoulders are not visible to this method.
#'
#' @keywords internal
.rank_fid <- function(fid, call = rlang::caller_env()) {
  if (
    !is.list(fid) ||
      !all(c("rt", "intensity") %in% names(fid)) ||
      length(fid$rt) != length(fid$intensity)
  ) {
    .moosaic_abort(
      "{.arg fid} must be a list with equal-length {.field rt} and {.field intensity}.",
      class = "bad_argument",
      call = call
    )
  }
  ok <- !is.na(fid$intensity)
  if (sum(ok) < 5L) {
    return(NA_integer_)
  }
  y <- stats::approx(fid$rt[ok], fid$intensity[ok], fid$rt, rule = 2)$y
  noise <- stats::mad(diff(y, differences = 3)) / sqrt(20)
  snr <- .get_moosaic_option("peak_min_height_snr")
  thr <- max(snr * noise, 0.05 * (max(y) - min(y)))
  maxima <- .find_local_maxima(y)
  if (length(maxima) == 0L) {
    return(0L)
  }
  as.integer(sum(.peak_prominence(y, maxima) > thr))
}
