#' Detect deconvolution windows from the FID
#'
#' Finds FID peaks (including shoulders) with [detect_peaks()] and merges them
#' into padded, localized windows with non-overlapping ownership cores.
#'
#' @param exp A `gcms_fid_exp` object.
#'
#' @return A tibble with `window_id`, `start_rt`, `end_rt` (FID time, min),
#'   `n_peaks`, `peak_ids`, `n_scans` (MS scans inside the window after
#'   removing the alignment delay) and `has_shoulder` (logical; any peak in
#'   the window has an unresolved shoulder). The peak table is attached as
#'   `attr(, "peaks")`. `exp` is not modified.
#'   Nonempty tables also contain `core_start_rt`, `core_end_rt` and
#'   `core_last`; a shared boundary belongs to the core on its right.
#'
#' @details Padding and merge gap come from the `moosaic.window_padding` and
#'   `moosaic.window_merge_gap` options. A warning is issued for windows with
#'   fewer than `moosaic.min_scans_per_window` scans.
#'   `moosaic.window_max_width` (default 0.5 min) limits core width and
#'   `moosaic.window_max_peaks` (default 4) limits detected apexes per core,
#'   except coincident apexes. Set both to `Inf` for legacy merged windows.
#'   Localized fit intervals are expanded when necessary to include at least
#'   two available MS scans; ownership cores are unchanged.
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
  peaks <- detect_peaks(exp$fid)
  windows <- .merge_overlapping_peaks(
    peaks,
    padding = .get_moosaic_option("window_padding"),
    gap = .get_moosaic_option("window_merge_gap"),
    max_width = .get_moosaic_option("window_max_width") %||% 0.5,
    max_peaks = .get_moosaic_option("window_max_peaks") %||% 4L
  )
  scan_rt <- exp$ms$rt - (exp$alignment$delay %||% 0)
  if ("core_start_rt" %in% names(windows) && length(scan_rt) >= 2L) {
    for (i in seq_len(nrow(windows))) {
      inside <- scan_rt >= windows$start_rt[i] & scan_rt <= windows$end_rt[i]
      if (sum(inside) < 2L) {
        mid <- mean(c(windows$core_start_rt[i], windows$core_end_rt[i]))
        nearest <- order(abs(scan_rt - mid))[1:2]
        windows$start_rt[i] <- min(windows$start_rt[i], scan_rt[nearest])
        windows$end_rt[i] <- max(windows$end_rt[i], scan_rt[nearest])
      }
    }
  }
  windows$n_scans <- vapply(
    seq_len(nrow(windows)),
    \(i) sum(scan_rt >= windows$start_rt[i] & scan_rt <= windows$end_rt[i]),
    integer(1)
  )
  windows$has_shoulder <- vapply(
    windows$peak_ids,
    \(ids) any(peaks$has_shoulder[peaks$peak_id %in% ids]),
    logical(1)
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
