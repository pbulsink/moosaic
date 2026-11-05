#' Prepare a detection copy of the FID trace
#'
#' Smooths then baseline-corrects a copy of the FID. The input is not
#' modified; use the raw trace for integration.
#'
#' @param fid List with numeric `rt` and `intensity` (the `fid` slot of a
#'   `gcms_fid_exp`).
#'
#' @return List with `rt`, `intensity` (smoothed, baseline-corrected) and
#'   `noise` (white-noise SD estimated from the unsmoothed trace).
#'
#' @details Window and baseline method come from the `moosaic.fid_smooth_window`
#'   and `moosaic.fid_baseline_method` options.
#'
#' @keywords internal
.preprocess_fid_for_detection <- function(fid) {
  window <- .get_moosaic_option("fid_smooth_window")
  method <- .get_moosaic_option("fid_baseline_method")
  smoothed <- .smooth_signal(fid$intensity, window)
  list(
    rt = fid$rt,
    intensity = .correct_baseline(smoothed, method),
    noise = .estimate_noise(fid$intensity)
  )
}
