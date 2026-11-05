#' Extract the MS data matrix for a window
#'
#' @param exp A `gcms_fid_exp` object, ideally after [align_detectors()].
#' @param window A one-row data frame such as a row of
#'   [detect_fid_windows()], or a list with numeric `start_rt`, `end_rt`
#'   (FID time axis, min) and optional `window_id`.
#'
#' @return A list with `D` (dense scans x m/z matrix), `rt` (scan times on the
#'   FID axis, i.e. MS time minus the alignment delay), `mz` (bin-centre m/z
#'   of the retained columns) and `window_id`.
#'
#' @details Scans whose aligned time lies in the window (inclusive) are kept.
#'   Only the window's rows are densified, and m/z channels with no signal in
#'   the window are removed. The m/z range and binning come from the
#'   `moosaic.mz_min`, `moosaic.mz_max` and `moosaic.mz_bin` options. Aborts
#'   with class `empty_window` if no scans fall inside the window.
#'
#' @examples
#' \dontrun{
#'   windows <- detect_fid_windows(exp)
#'   m <- extract_ms_matrix(exp, windows[1, ])
#' }
#'
#' @export
extract_ms_matrix <- function(exp, window) {
  call <- rlang::current_env()
  if (!is_gcms_fid_exp(exp)) {
    .moosaic_abort(
      "{.arg exp} must be a {.cls gcms_fid_exp} object.",
      class = "bad_argument",
      call = call
    )
  }
  w <- .parse_window(window, call = call)
  delay <- exp$alignment$delay %||% 0
  scan_rt <- .apply_alignment(exp$ms$rt, delay)
  keep <- which(scan_rt >= w$start_rt & scan_rt <= w$end_rt)
  if (length(keep) == 0L) {
    .moosaic_abort(
      "No MS scans between {w$start_rt} and {w$end_rt} min.",
      class = "empty_window",
      call = call
    )
  }
  rt_raw <- exp$ms$rt[keep]
  rows <- exp$ms$data[, 1] %in% rt_raw
  ms_sub <- list(data = exp$ms$data[rows, , drop = FALSE], rt = rt_raw)
  built <- build_ms_matrix(ms_sub)
  D <- .drop_empty_mz(built$D)
  list(
    D = D,
    rt = scan_rt[keep],
    mz = as.numeric(colnames(D)),
    window_id = w$window_id
  )
}
