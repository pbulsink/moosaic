#' Leading singular values of a matrix
#'
#' @param X Numeric matrix.
#' @param k Integer; number of singular values wanted.
#'
#' @return Numeric vector of the `min(k, min(dim(X)))` largest singular
#'   values, in decreasing order.
#'
#' @details Computed as square roots of the eigenvalues of the smaller Gram
#'   matrix (`X X'` or `X' X`), which is several times faster than a full SVD
#'   for the wide matrices used here. Accuracy is about 1e-8 relative to the
#'   largest value, which is ample for rank decisions but not for recovering
#'   tiny singular values.
#'
#' @keywords internal
.leading_singular_values <- function(X, k) {
  k <- min(k, dim(X))
  G <- if (nrow(X) <= ncol(X)) tcrossprod(X) else crossprod(X)
  ev <- eigen(G, symmetric = TRUE, only.values = TRUE)$values
  sqrt(pmax(ev[seq_len(k)], 0))
}
