#' Fit external calibration curves
#'
#' @param points Calibration points: a data frame with columns `target`,
#'   `conc` and `resp`.
#' @param style One of `"slope"` (through the origin), `"slope_intercept"` or
#'   `"quadratic"`.
#'
#' @return A tibble with one row per target: `target`, `n_points`,
#'   `intercept`, `slope`, `quad` (concentration as a function of response)
#'   and `r2`. Coefficients not part of `style` are 0; all are `NA` when
#'   too few points remain.
#'
#' @details Points with missing values or a response of zero are treated as
#'   below detection and excluded. For `"slope"`, `r2` is the uncentered
#'   coefficient of determination of the regression through the origin.
#'
#' @keywords internal
.fit_calibration <- function(
  points,
  style = c("slope", "slope_intercept", "quadratic")
) {
  style <- rlang::arg_match(style)
  need <- c(slope = 1L, slope_intercept = 2L, quadratic = 3L)[[style]]
  fit_one <- \(d) {
    d <- d[!is.na(d$conc) & !is.na(d$resp) & d$resp > 0, , drop = FALSE]
    co <- c(intercept = NA_real_, slope = NA_real_, quad = NA_real_)
    r2 <- NA_real_
    if (nrow(d) >= need) {
      x <- switch(
        style,
        slope = cbind(d$resp),
        slope_intercept = cbind(1, d$resp),
        quadratic = cbind(1, d$resp, d$resp^2)
      )
      fit <- stats::lm.fit(x, d$conc)
      b <- unname(fit$coefficients)
      co[] <- switch(
        style,
        slope = c(0, b, 0),
        slope_intercept = c(b, 0),
        quadratic = b
      )
      sst <- if (style == "slope") {
        sum(d$conc^2)
      } else {
        sum((d$conc - mean(d$conc))^2)
      }
      if (sst > 0) {
        r2 <- 1 - sum(fit$residuals^2) / sst
      }
    }
    tibble::tibble(
      target = d$target[1] %||% NA_character_,
      n_points = nrow(d),
      intercept = co[["intercept"]],
      slope = co[["slope"]],
      quad = co[["quad"]],
      r2 = r2
    )
  }
  groups <- split(points, factor(points$target, unique(points$target)))
  tibble::as_tibble(do.call(rbind, lapply(groups, fit_one)))
}
