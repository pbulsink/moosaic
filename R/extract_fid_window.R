#' FID signal resampled onto a window's MS scans
#'
#' @param exp A `gcms_fid_exp` object.
#' @param window A window (see [extract_ms_matrix()]).
#' @param raw Logical. `TRUE` uses the raw FID; `FALSE` (default) uses the
#'   smoothed, baseline-corrected detection copy.
#' @param call Call environment for errors.
#'
#' @return A list with `rt` (aligned scan times, identical to
#'   `extract_ms_matrix()$rt`) and `intensity` (boxcar-mean FID per scan, so
#'   one value per row of `D`).
#'
#' @details The detection copy is computed from the whole trace on every
#'   call, which is the dominant cost for long runs. `exp` is not modified.
#'
#' @keywords internal
.extract_fid_window <- function(
  exp,
  window,
  raw = FALSE,
  call = rlang::caller_env()
) {
  w <- .parse_window(window, call = call)
  scan_rt <- .apply_alignment(exp$ms$rt, exp$alignment$delay %||% 0)
  in_win <- which(scan_rt >= w$start_rt & scan_rt <= w$end_rt)
  if (length(in_win) == 0L) {
    .moosaic_abort(
      "No MS scans between {w$start_rt} and {w$end_rt} min.",
      class = "empty_window",
      call = call
    )
  }
  fid <- if (raw) exp$fid else .preprocess_fid_for_detection(exp$fid)
  y <- .resample_fid_to_scans(
    fid$rt,
    fid$intensity,
    scan_rt[in_win],
    call = call
  )
  list(rt = scan_rt[in_win], intensity = y)
}
