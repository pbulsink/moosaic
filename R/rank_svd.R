#' Rank estimate from cumulative explained variance
#'
#' @param D Numeric matrix, scans x m/z.
#' @param threshold Numeric in (0, 1]; fraction of total squared signal that
#'   the retained components must explain.
#' @param call Call environment for errors.
#'
#' @return Integer; the smallest number of singular components whose
#'   cumulative squared singular values reach `threshold` of the total, or 0
#'   for an all-zero matrix.
#'
#' @details Uncentred, so a constant background counts towards the first
#'   component. On noisy data the result grows with the noise; it is
#'   an upper-leaning vote.
#'
#' @keywords internal
.rank_svd <- function(D, threshold, call = rlang::caller_env()) {
  if (
    !is.numeric(threshold) ||
      length(threshold) != 1L ||
      is.na(threshold) ||
      threshold <= 0 ||
      threshold > 1
  ) {
    .moosaic_abort(
      "{.arg threshold} must be a single number in (0, 1].",
      class = "bad_argument",
      call = call
    )
  }
  s2 <- svd(D, nu = 0, nv = 0)$d^2
  total <- sum(s2)
  if (total == 0) {
    return(0L)
  }
  as.integer(which(cumsum(s2) / total >= threshold - 1e-10)[1])
}
