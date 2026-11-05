#' Check the raw FID baseline
#'
#' @param fid List with numeric `rt` and `intensity` (at least 20 points), as
#'   in a `gcms_fid_exp$fid`.
#' @param tol_snr Tolerance, in multiples of the noise level, for the baseline
#'   offset at the start of the run and for departures from a straight line.
#'
#' @return Invisibly, a list with `ok`, `offset` (fitted baseline at the first
#'   point), `slope` (per minute), `curvature` (largest departure of the
#'   baseline from the fitted line) and `noise`.
#'
#' @details The baseline is estimated in ten equal blocks as the 10th
#'   percentile (corrected for noise), which peaks barely affect, then fitted
#'   with a line. Polyarc quantification assumes a baseline near zero or a
#'   straight drift. A curved baseline warns with class
#'   `moosaic-warning-fid_baseline_curved`; an offset beyond tolerance warns
#'   with class `moosaic-warning-fid_baseline_offset`. The intensities are
#'   never modified.
#'
#' @keywords internal
.check_fid_baseline <- function(fid, tol_snr = 5) {
  call <- rlang::current_env()
  if (
    !is.list(fid) ||
      !is.numeric(fid$rt) ||
      !is.numeric(fid$intensity) ||
      length(fid$rt) != length(fid$intensity) ||
      length(fid$rt) < 20L
  ) {
    .moosaic_abort(
      "{.arg fid} must be a list with numeric {.field rt} and {.field intensity} of equal length (at least 20).",
      class = "bad_argument",
      call = call
    )
  }
  noise <- .estimate_noise(fid$intensity)
  block <- cut(seq_along(fid$rt), breaks = 10L, labels = FALSE)
  level <- tapply(
    fid$intensity,
    block,
    stats::quantile,
    probs = 0.1,
    names = FALSE
  ) +
    stats::qnorm(0.9) * noise
  centre <- tapply(fid$rt, block, mean)
  fit <- stats::lm.fit(cbind(1, as.numeric(centre)), as.numeric(level))
  slope <- fit$coefficients[[2]]
  offset <- fit$coefficients[[1]] + slope * fid$rt[1]
  curvature <- max(abs(fit$residuals))
  tol <- tol_snr * noise
  ok <- curvature <= tol && abs(offset) <= tol
  if (curvature > tol) {
    .moosaic_warn(
      "FID baseline is curved (departs from a straight line by {signif(curvature, 3)}); Polyarc areas may be biased.",
      class = "fid_baseline_curved",
      call = call
    )
  } else if (abs(offset) > tol) {
    .moosaic_warn(
      "FID baseline is offset from zero by {signif(offset, 3)}; Polyarc areas may be biased.",
      class = "fid_baseline_offset",
      call = call
    )
  }
  invisible(list(
    ok = ok,
    offset = offset,
    slope = slope,
    curvature = curvature,
    noise = noise
  ))
}
