#' Retention index from retention time
#'
#' @param rt Numeric vector of retention times (min).
#' @param ri_cal Data frame with `rt` and `ri` of the reference compounds
#'   (see [read_ri_calibration()]).
#' @param call Call environment for conditions.
#'
#' @return Numeric vector of RI values, by piecewise linear interpolation
#'   between neighbouring references (van den Dool and Kratz). Times outside
#'   the calibrated range give `NA` with a warning, unless
#'   `moosaic.ri_extrapolate` is `TRUE`, in which case the nearest two
#'   references are extrapolated linearly.
#'
#' @keywords internal
.compute_ri <- function(rt, ri_cal, call = rlang::caller_env()) {
  if (!is.data.frame(ri_cal) || nrow(ri_cal) < 2L) {
    .moosaic_abort(
      "{.arg ri_cal} needs at least 2 reference compounds.",
      class = "bad_calibration",
      call = call
    )
  }
  o <- order(ri_cal$rt)
  x <- ri_cal$rt[o]
  y <- ri_cal$ri[o]
  n <- length(x)
  out <- stats::approx(x, y, rt, rule = 1, ties = "ordered")$y
  low <- !is.na(rt) & rt < x[1]
  high <- !is.na(rt) & rt > x[n]
  if (isTRUE(.get_moosaic_option("ri_extrapolate"))) {
    out[low] <- y[1] + (y[2] - y[1]) / (x[2] - x[1]) * (rt[low] - x[1])
    out[high] <- y[n] +
      (y[n] - y[n - 1L]) / (x[n] - x[n - 1L]) * (rt[high] - x[n])
  } else if (any(low | high)) {
    .moosaic_warn(
      "{sum(low | high)} retention time{?s} outside the calibrated range ({x[1]} to {x[n]} min); RI set to {.code NA}.",
      class = "ri_out_of_range",
      call = call
    )
  }
  out
}
