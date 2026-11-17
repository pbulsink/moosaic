#' Prepare a detection copy of a chromatographic trace
#'
#' Smooths then baseline-corrects a copy of a trace (FID or TIC). The input is
#' not modified; use the raw trace for integration.
#'
#' @param trace List with numeric `rt` and `intensity` (e.g. the `fid` slot of
#'   a `gcms_fid_exp`, or a TIC).
#' @param smooth_window Odd integer; Savitzky-Golay window in points. `NULL`
#'   uses the `moosaic.fid_smooth_window` option.
#'
#' @return List with `rt`, `intensity` (smoothed, baseline-corrected) and
#'   `noise` (white-noise SD estimated from the unsmoothed trace).
#'
#' @details The baseline method comes from the `moosaic.fid_baseline_method`
#'   option. The window is in points, so traces sampled at different rates
#'   need different windows for the same smoothing in time.
#'
#' @keywords internal
.preprocess_for_detection <- function(trace, smooth_window = NULL) {
  window <- smooth_window %||% .get_moosaic_option("fid_smooth_window")
  method <- .get_moosaic_option("fid_baseline_method")
  smoothed <- .smooth_signal(trace$intensity, window)
  list(
    rt = trace$rt,
    intensity = .correct_baseline(smoothed, method),
    noise = .estimate_noise(trace$intensity)
  )
}
