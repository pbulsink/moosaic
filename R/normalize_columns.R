#' Scale matrix columns to a maximum of 1
#'
#' @param M Numeric matrix.
#'
#' @return `M` with each column divided by its maximum. Columns whose maximum
#'   is not positive are returned as zeros.
#'
#' @keywords internal
.normalize_columns <- function(M) {
  mx <- apply(M, 2, max)
  mx[!is.finite(mx) | mx <= 0] <- 1
  sweep(M, 2, mx, "/")
}
