#' Deconvolve one window
#'
#' Extracts the window's MS matrix and FID, estimates the rank, builds FID
#' constraints, fits by MCR-ALS and assembles components.
#'
#' @param window A one-row data frame such as a row of [detect_fid_windows()],
#'   or a list with `start_rt`, `end_rt` and optional `window_id`.
#' @param exp A `gcms_fid_exp` object, ideally after [align_detectors()].
#'
#' @return A list of `moosaic_component` objects. A flat background component
#'   is added last when `moosaic.background_component` is `TRUE`.
#'
#' @export
process_window <- function(window, exp) {
  call <- rlang::current_env()
  if (!is_gcms_fid_exp(exp)) {
    .moosaic_abort(
      "{.arg exp} must be a {.cls gcms_fid_exp} object.",
      class = "bad_argument",
      call = call
    )
  }
  bg <- isTRUE(.get_moosaic_option("background_component"))
  mm <- extract_ms_matrix(exp, window)
  fid_det <- .extract_fid_window(exp, window, call = call)
  rk <- estimate_rank(mm$D, fid_det)
  cons <- build_constraints(fid_det, rk$rank, background = bg)
  fit <- fit_window(mm$D, rk$rank, cons$C0, background = bg)
  fid_raw <- .extract_fid_window(exp, window, raw = TRUE, call = call)
  .build_components(fit, fid_raw, window, background = bg, call = call)
}
