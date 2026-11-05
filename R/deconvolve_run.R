#' Deconvolve every FID window of a run
#'
#' @param exp A `gcms_fid_exp` object, ideally after [align_detectors()].
#'
#' @return A `moosaic_result`: a list with `components` (all
#'   `moosaic_component`s, in window order) and `windows` (the
#'   [detect_fid_windows()] table).
#'
#' @export
deconvolve_run <- function(exp) {
  if (!is_gcms_fid_exp(exp)) {
    .moosaic_abort(
      "{.arg exp} must be a {.cls gcms_fid_exp} object.",
      class = "bad_argument",
      call = rlang::current_env()
    )
  }
  windows <- detect_fid_windows(exp)
  comps <- lapply(
    seq_len(nrow(windows)),
    \(i) process_window(windows[i, ], exp)
  )
  structure(
    list(components = unlist(comps, recursive = FALSE), windows = windows),
    class = "moosaic_result"
  )
}
