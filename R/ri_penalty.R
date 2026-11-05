#' Retention index penalty
#'
#' @param observed,library Numeric vectors of observed and library RI.
#' @param grace Differences up to this size are not penalised.
#' @param per_unit Penalty per RI unit beyond `grace`.
#'
#' @return A tibble with `penalty` and `ri_missing` (`TRUE` where either RI
#'   is `NA`; the penalty is then 0).
#'
#' @keywords internal
.ri_penalty <- function(observed, library, grace, per_unit) {
  missing <- is.na(observed) | is.na(library)
  pen <- pmax(0, abs(observed - library) - grace) * per_unit
  pen[missing] <- 0
  tibble::tibble(penalty = pen, ri_missing = missing)
}
