#' Flat background profile
#'
#' @param n Integer; number of scans.
#'
#' @return Numeric vector of `n` ones.
#'
#' @keywords internal
.background_profile <- function(n) {
  rep(1, n)
}
