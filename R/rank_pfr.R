#' Rank estimate by sequential pseudo F-ratios
#'
#' @param D Numeric matrix, scans x m/z.
#' @param cutoff Numeric in (0, 1); F-distribution probability a ratio must
#'   reach to count as signal.
#' @param max_rank Integer; largest rank considered.
#' @param call Call environment for errors.
#'
#' @return Integer; the largest `k` (capped at `max_rank`) whose ratio
#'   \eqn{s_k^2 / s_{k+1}^2} of consecutive squared singular values has an
#'   F-distribution probability of at least `cutoff`. 0 when no ratio does or
#'   `D` is all zero; `NA` when `D` has fewer than 3 rows or 2 columns.
#'
#' @details Adapts the pseudo F-ratio of Giebelhaus et al. (2022,
#'   \doi{10.1016/j.chroma.2022.463499}), who compare \eqn{s_1^2 / s_2^2} of a
#'   moving window against an F distribution with `(w - 1, w - 2)` degrees of
#'   freedom, `w` being the number of scans. Here the whole window is the
#'   moving window and every consecutive ratio is tested. Two deviations from
#'   the paper, both chosen on simulated windows:
#'
#'   * No autoscaling. Scaling every m/z channel to unit variance lets the
#'     many noise-only channels mask minor components.
#'   * The rank is the last significant ratio, not the count of leading
#'     significant ones. Two noise singular values give ratios near 1, but a
#'     ratio between two signal components can also be small, so stopping
#'     at the first failure under-counts.
#'
#'   The F reference is a heuristic (the paper gives no proof), so `cutoff`
#'   is a tuning value, not a significance level. Singular values below
#'   `1e-6` of the largest are treated as zero.
#'
#' @keywords internal
.rank_pfr <- function(D, cutoff, max_rank, call = rlang::caller_env()) {
  if (
    !is.numeric(cutoff) ||
      length(cutoff) != 1L ||
      is.na(cutoff) ||
      cutoff <= 0 ||
      cutoff >= 1
  ) {
    .moosaic_abort(
      "{.arg cutoff} must be a single number in (0, 1).",
      class = "bad_argument",
      call = call
    )
  }
  w <- nrow(D)
  if (w < 3L || ncol(D) < 2L) {
    return(NA_integer_)
  }
  # Test one ratio past max_rank so a higher true rank still caps to
  # max_rank, but no further: the smallest noise singular values fall off
  # steeply and give spuriously large ratios
  K <- min(max_rank + 1L, min(dim(D)) - 1L)
  s2 <- .leading_singular_values(D, K + 1L)^2
  if (s2[1] == 0) {
    return(0L)
  }
  s2[s2 < 1e-12 * s2[1]] <- 0
  ratio <- s2[-length(s2)] / s2[-1]
  # 0/0 beyond the numerical rank is not signal; x/0 is
  p <- ifelse(is.nan(ratio), 0, stats::pf(ratio, w - 1, w - 2))
  sig <- which(p >= cutoff)
  if (length(sig) == 0L) 0L else as.integer(min(max(sig), max_rank))
}
