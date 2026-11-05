#' Evaluate calibration curves
#'
#' @param area Numeric vector of FID areas.
#' @param curve Tibble with columns `intercept`, `slope` and `quad`, one row
#'   per element of `area` (see `.fit_calibration()`).
#'
#' @return Numeric vector of amounts, clipped at zero.
#'
#' @keywords internal
.apply_curve <- function(area, curve) {
  pmax(curve$intercept + curve$slope * area + curve$quad * area^2, 0)
}
