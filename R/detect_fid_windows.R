#' Detect deconvolution windows from the FID
#'
#' Finds FID peaks with [detect_fid_peaks()] and merges them into padded
#' windows.
#'
#' @param exp A `gcms_fid_exp` object.
#'
#' @return A tibble with `window_id`, `start_rt`, `end_rt` (FID time, min),
#'   `n_peaks`, `peak_ids` and `n_scans` (MS scans inside the window after
#'   removing the alignment delay). The peak table is attached as
#'   `attr(, "peaks")`. `exp` is not modified.
#'
#' @details Padding and merge gap come from the `moosaic.window_padding` and
#'   `moosaic.window_merge_gap` options. A warning is issued for windows with
#'   fewer than `moosaic.min_scans_per_window` scans.
#'
#' @examples
#' \dontrun{
#'   windows <- detect_fid_windows(exp)
#' }
#'
#' @export
detect_fid_windows <- function(exp) {
  if (!is_gcms_fid_exp(exp)) {
    .moosaic_abort(
      "{.arg exp} must be a {.cls gcms_fid_exp} object.",
      class = "bad_argument",
      call = rlang::current_env()
    )
  }
  peaks <- detect_fid_peaks(exp$fid)
  windows <- .merge_overlapping_peaks(
    peaks,
    padding = .get_moosaic_option("window_padding"),
    gap = .get_moosaic_option("window_merge_gap")
  )
  scan_rt <- exp$ms$rt - (exp$alignment$delay %||% 0)
  windows$n_scans <- vapply(
    seq_len(nrow(windows)),
    \(i) sum(scan_rt >= windows$start_rt[i] & scan_rt <= windows$end_rt[i]),
    integer(1)
  )
  min_scans <- .get_moosaic_option("min_scans_per_window")
  few <- windows$window_id[windows$n_scans < min_scans]
  if (length(few) > 0L) {
    n_few <- length(few)
    few_ids <- paste(few, collapse = ", ")
    .moosaic_warn(
      c(
        "{.fn detect_fid_windows}: {n_few} window{?s} ha{?s/ve} fewer than {min_scans} MS scans.",
        i = "Window id{cli::qty(n_few)}{?s}: {few_ids}"
      ),
      class = "few_scans",
      call = rlang::current_env()
    )
  }
  attr(windows, "peaks") <- peaks
  windows
}
