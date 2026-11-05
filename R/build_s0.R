#' Initial spectra estimate from SVD
#'
#' @param D Numeric matrix, scans x m/z.
#' @param rank Integer; number of components.
#' @param call Call environment for errors.
#'
#' @return Numeric matrix, `ncol(D)` x `rank`, non-negative with each column
#'   scaled to a maximum of 1 (all-zero columns stay zero).
#'
#' @details Uses the absolute values of the leading right singular vectors.
#'
#' @keywords internal
.build_s0 <- function(D, rank, call = rlang::caller_env()) {
  if (
    !is.numeric(rank) || length(rank) != 1L || rank < 1 || rank != round(rank)
  ) {
    .moosaic_abort(
      "{.arg rank} must be a positive integer.",
      class = "bad_argument",
      call = call
    )
  }
  if (rank > min(dim(D))) {
    .moosaic_abort(
      "{.arg rank} ({rank}) exceeds the smallest dimension of {.arg D} ({min(dim(D))}).",
      class = "bad_rank",
      call = call
    )
  }
  v <- svd(D, nu = 0, nv = rank)$v
  S0 <- abs(v)
  mx <- apply(S0, 2, max)
  mx[mx == 0] <- 1
  S0 <- sweep(S0, 2, mx, "/")
  dimnames(S0) <- list(colnames(D), NULL)
  S0
}
