#' Rank estimate by BIC
#'
#' @param D Numeric matrix, scans x m/z.
#' @param max_rank Integer; largest rank considered.
#'
#' @return Integer; the rank in `0:max_rank` minimising the BIC of a rank-k
#'   model with iid Gaussian residuals, or `NA` when `D` has a single row or
#'   column (not estimable). 0 for an all-zero matrix or pure noise.
#'
#' @details Residual sums of squares come from the discarded singular values.
#'   The residual is floored at (1e-6 times the largest singular value)^2 so
#'   that floating-point noise in noiseless data does not drive the choice,
#'   and ranks are limited to `min(dim(D)) - 1` so the model never fits
#'   exactly. The free-parameter count is `k * (nrow + ncol - k)`.
#'
#' @keywords internal
.rank_bic <- function(D, max_rank) {
  s <- svd(D, nu = 0, nv = 0)$d
  if (s[1] == 0) {
    return(0L)
  }
  m <- nrow(D)
  p <- ncol(D)
  K <- min(max_rank, min(m, p) - 1L)
  if (K < 1L) {
    return(NA_integer_)
  }
  n_obs <- m * p
  ks <- 0:K
  tails <- c(rev(cumsum(rev(s^2))), 0)
  rss <- pmax(tails[ks + 1L], (1e-6 * s[1])^2)
  bic <- n_obs * log(rss / n_obs) + ks * (m + p - ks) * log(n_obs)
  as.integer(ks[which.min(bic)])
}
