#' Subtract an estimated baseline
#'
#' @param x Numeric vector.
#' @param method One of `"rolling_min"` or `"none"`. `"rolling_min"` is a
#'   morphological opening (running minimum then running maximum) followed by
#'   a moving average, so features narrower than `window` are treated as
#'   signal and a linear drift is removed exactly.
#' @param window Odd integer; window in points. `NULL` uses about 5% of
#'   `length(x)` (minimum 11), which should exceed the base width of the
#'   widest peak.
#'
#' @return Numeric vector, same length as `x`.
#'
#' @keywords internal
.correct_baseline <- function(
  x,
  method = c("rolling_min", "none"),
  window = NULL
) {
  method <- rlang::arg_match(method)
  if (method == "none") {
    return(x)
  }
  window <- window %||% max(11L, round(length(x) * 0.05))
  window <- as.integer(window)
  if (window %% 2L == 0L) {
    window <- window + 1L
  }
  window <- min(window, 2L * ((length(x) - 1L) %/% 2L) + 1L)
  opened <- -.running_min(-.running_min(x, window), window)
  baseline <- .apply_filter(opened, rep(1 / window, window))
  x - baseline
}
