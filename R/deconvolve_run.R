#' Deconvolve every FID window of a run
#'
#' @param exp A `gcms_fid_exp` object, ideally after [align_detectors()].
#' @param verbose Logical; display a progress bar. Defaults to `FALSE`.
#'
#' @return A `moosaic_result`: a list with `components` (all
#'   `moosaic_component`s, in window order) and `windows` (the
#'   [detect_fid_windows()] table).
#'
#' @details Localized fits overlap for context. Only components whose apex is
#'   owned by each window's core are returned, avoiding repeated assignment
#'   of an identical boundary apex. Shifted duplicate estimates can remain.
#' @examples
#' \dontrun{
#' result <- deconvolve_run(exp)
#' }
#'
#' @export
deconvolve_run <- function(exp, verbose = FALSE) {
  if (!is_gcms_fid_exp(exp)) {
    .moosaic_abort(
      "{.arg exp} must be a {.cls gcms_fid_exp} object.",
      class = "bad_argument",
      call = rlang::current_env()
    )
  }
  if (!rlang::is_bool(verbose)) {
    .moosaic_abort(
      "{.fn deconvolve_run}: {.arg verbose} must be TRUE or FALSE.",
      class = "bad_argument",
      call = rlang::current_env()
    )
  }
  windows <- detect_fid_windows(exp)
  verbose <- verbose && nrow(windows) > 0L
  if (verbose) {
    .moosaic_inform("Deconvoluting spectral windows:")
    pb <- utils::txtProgressBar(min = 0, max = nrow(windows), style = 3)
    on.exit(close(pb), add = TRUE)
  }
  comps <- lapply(
    seq_len(nrow(windows)),
    \(i) {
      if (verbose) {
        utils::setTxtProgressBar(pb, i)
      }
      process_window(windows[i, ], exp)
    }
  )

  structure(
    list(components = unlist(comps, recursive = FALSE), windows = windows),
    class = "moosaic_result"
  )
}
