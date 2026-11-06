#' Align MS and FID retention times
#'
#' Estimates the retention-time delay between the MS and the FID and records
#' it in the experiment. Raw times are never changed; downstream functions
#' subtract the delay from MS times.
#'
#' @param exp A `gcms_fid_exp` object.
#' @param engine `"xcorr"` (default) or `"gcalignr"`. `NULL` uses the
#'   `moosaic.align_engine` option.
#'
#' @return `exp` with `alignment` set to a list of `delay` (min; positive when
#'   MS times are later than FID times), `engine`, `score` (cross-correlation
#'   at the delay), `validated` (`FALSE`) and `cross_check` (`engine` and
#'   `delay` of the xcorr cross-check; both `NA` when no cross-check was run).
#'   The step is logged in `processing$align_detectors`.
#'
#' @details Cross-correlation alone is sufficient to align the FID with the MS
#'   for guiding deconvolution windows, so with `engine = "xcorr"` GCalignR is
#'   not run. With `engine = "gcalignr"`, xcorr is run as a cheap cross-check;
#'   a warning of class `engine_disagreement` is issued when the two delays
#'   differ by more than one MS scan interval. If GCalignR cannot run because
#'   too few peaks are found, the cross-correlation result is used with a
#'   warning of class `engine_fallback`. Search range and step come from the
#'   `moosaic.max_delay` and `moosaic.align_step` options.
#'
#' @examples
#' \dontrun{
#'   exp <- align_detectors(exp)
#' }
#'
#' @export
align_detectors <- function(exp, engine = NULL) {
  call <- rlang::current_env()
  if (!is_gcms_fid_exp(exp)) {
    .moosaic_abort(
      "{.arg exp} must be a {.cls gcms_fid_exp} object.",
      class = "bad_argument",
      call = call
    )
  }
  engine <- engine %||% .get_moosaic_option("align_engine")
  max_delay <- .get_moosaic_option("max_delay")
  step <- .get_moosaic_option("align_step")
  tic <- list(rt = exp$ms$rt, intensity = exp$ms$tic)

  primary <- tryCatch(
    .estimate_delay(exp$fid, tic, engine, max_delay, step, call = call),
    `moosaic-error-too_few_peaks` = \(e) {
      .moosaic_warn(
        "GCalignR could not run (too few peaks); using {.val xcorr} instead.",
        class = "engine_fallback",
        call = call
      )
      .estimate_delay(exp$fid, tic, "xcorr", max_delay, step, call = call)
    }
  )

  # xcorr is sufficient for FID-guided windowing; GCalignR is slow and only
  # worth running when explicitly requested, so it is never a cross-check.
  check <- if (primary$engine == "gcalignr") {
    .estimate_delay(exp$fid, tic, "xcorr", max_delay, step, call = call)
  } else {
    list(delay = NA_real_, engine = NA_character_, score = NA_real_)
  }

  scan_step <- stats::median(diff(exp$ms$rt))
  if (!is.na(check$delay) && abs(check$delay - primary$delay) > scan_step) {
    .moosaic_warn(
      c(
        "Alignment engines disagree by more than one MS scan.",
        i = "{primary$engine}: {signif(primary$delay, 4)} min; {check$engine}: {signif(check$delay, 4)} min."
      ),
      class = "engine_disagreement",
      call = call
    )
  }

  score <- if (primary$engine == "xcorr") primary$score else check$score
  exp$alignment <- list(
    delay = primary$delay,
    engine = primary$engine,
    score = score,
    validated = FALSE,
    cross_check = list(engine = check$engine, delay = check$delay)
  )
  exp$processing$align_detectors <- list(
    engine = primary$engine,
    max_delay = max_delay,
    step = step
  )
  exp
}
