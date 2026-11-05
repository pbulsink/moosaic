#' Consensus of rank votes
#'
#' @param votes Numeric vector of rank estimates, one per method (named or
#'   not). `NA` votes are ignored.
#' @param call Call environment for errors.
#'
#' @return A list with `rank` (integer; the most common vote, ties going to
#'   the higher rank) and `confidence` (the share of usable votes equal to
#'   `rank`).
#'
#' @keywords internal
.consensus_rank <- function(votes, call = rlang::caller_env()) {
  votes <- votes[!is.na(votes)]
  if (length(votes) == 0L) {
    .moosaic_abort(
      "No usable rank votes to combine.",
      class = "no_votes",
      call = call
    )
  }
  counts <- table(as.integer(votes))
  best <- as.integer(names(counts))[counts == max(counts)]
  rank <- max(best)
  list(rank = as.integer(rank), confidence = max(counts) / length(votes))
}
