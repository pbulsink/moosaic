#' Fit diagnostics for an ALS solution
#'
#' @param D Numeric matrix, scans x m/z.
#' @param C,S Fitted concentrations (scans x comp) and spectra (m/z x comp).
#' @param fit List with `iter`, `converged` and `rd_final` (see
#'   `.from_als_output()`).
#'
#' @return List with `lack_of_fit` (percent), `r2`, `iter`, `converged`,
#'   `rd_final` and `explained_variance` (per component, fraction of
#'   `sum(D^2)`).
#'
#' @keywords internal
.als_diagnostics <- function(D, C, S, fit) {
  tot <- sum(D^2)
  recon <- C %*% t(S)
  rss <- sum((D - recon)^2)
  ev <- vapply(
    seq_len(ncol(C)),
    \(k) sum(outer(C[, k], S[, k])^2) / tot,
    numeric(1)
  )
  list(
    lack_of_fit = 100 * sqrt(rss / tot),
    r2 = 1 - rss / sum((D - mean(D))^2),
    iter = fit$iter,
    converged = fit$converged,
    rd_final = fit$rd_final,
    explained_variance = ev
  )
}
