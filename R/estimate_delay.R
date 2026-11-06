#' Estimate the MS-to-FID delay with a chosen engine
#'
#' @param fid,tic Lists with numeric `rt` and `intensity`; the FID trace and
#'   the MS total ion chromatogram.
#' @param engine One of `"gcalignr"` or `"xcorr"`.
#' @param max_delay Numeric; largest delay magnitude searched (min).
#' @param step Numeric; search step (min).
#' @param call Call environment for errors and warnings.
#'
#' @return A list with `delay` (min; positive when MS times are later),
#'   `engine`, and `score` (correlation for `"xcorr"`, `NA` for `"gcalignr"`).
#'
#' @details Warns with class `delay_at_limit` when the estimate is within one
#'   `step` of `max_delay`, since the true delay may lie outside the search
#'   range.
#'
#' @keywords internal
.estimate_delay <- function(
  fid,
  tic,
  engine,
  max_delay = 0.1,
  step = 0.001,

  call = rlang::caller_env()
) {
  if (
    !is.character(engine) ||
      length(engine) != 1L ||
      !engine %in% c("gcalignr", "xcorr")
  ) {
    .moosaic_abort(
      "Unknown alignment engine {.val {engine}}; use {.val gcalignr} or {.val xcorr}.",
      class = "unknown_engine",
      call = call
    )
  }
  res <- switch(
    engine,
    gcalignr = list(
      delay = .estimate_delay_gcalignr(
        detect_fid_peaks(fid),
        detect_fid_peaks(tic),
        max_delay,
        step,
        call = call
      ),
      score = NA_real_
    ),
    xcorr = .estimate_delay_xcorr(fid, tic, max_delay, step)
  )
  if (abs(res$delay) >= max_delay - step) {
    .moosaic_warn(
      "Estimated delay ({signif(res$delay, 3)} min) is at the search limit ({max_delay} min); the true delay may be larger.",
      class = "delay_at_limit",
      call = call
    )
  }
  list(delay = res$delay, engine = engine, score = res$score)
}
