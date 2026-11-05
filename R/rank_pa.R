#' Rank estimate by parallel analysis
#'
#' @param D Numeric matrix, scans x m/z.
#' @param iterations Positive integer; number of column-permuted copies.
#' @param max_rank Integer; largest rank considered.
#' @param call Call environment for errors.
#'
#' @return Integer; the number of leading singular values of the
#'   column-centred `D` that exceed the 95th percentile of the corresponding
#'   values from `iterations` copies with each column independently
#'   permuted. 0 for an all-zero matrix or pure noise. Uses the random number
#'   generator.
#'
#' @details Permuting columns keeps each channel's distribution but destroys
#'   the correlation between channels, so only structure shared across m/z
#'   channels exceeds the reference.
#'
#' @keywords internal
.rank_pa <- function(D, iterations, max_rank, call = rlang::caller_env()) {
  if (
    !is.numeric(iterations) ||
      length(iterations) != 1L ||
      is.na(iterations) ||
      iterations < 1 ||
      iterations != round(iterations)
  ) {
    .moosaic_abort(
      "{.arg iterations} must be a positive whole number.",
      class = "bad_argument",
      call = call
    )
  }
  Dc <- sweep(D, 2, colMeans(D))
  K <- min(max_rank, min(dim(D)))
  s <- .leading_singular_values(Dc, K)
  K <- length(s)
  if (s[1] == 0) {
    return(0L)
  }
  null <- matrix(0, K, iterations)
  # cli shows the bar only if this takes more than a couple of seconds
  for (i in cli::cli_progress_along(
    seq_len(iterations),
    "Parallel analysis",
    clear = TRUE
  )) {
    null[, i] <- .leading_singular_values(.permute_columns(Dc), K)
  }
  ref <- apply(null, 1, stats::quantile, probs = 0.95)
  exceed <- s > ref * (1 + 1e-8)
  as.integer(match(FALSE, exceed, nomatch = K + 1L) - 1L)
}
