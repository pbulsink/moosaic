#' Permute each column of a matrix independently
#'
#' @param X Numeric matrix.
#'
#' @return Matrix of the same dimensions with the entries of every column
#'   shuffled independently. Uses the random number generator.
#'
#' @details One sort of column index plus uniform noise shuffles all columns
#'   at once, which is faster than calling `sample()` per column.
#'
#' @keywords internal
.permute_columns <- function(X) {
  m <- nrow(X)
  p <- ncol(X)
  o <- order(rep(seq_len(p), each = m) + stats::runif(m * p))
  matrix(X[o], m, p)
}
