#' Combine match factor and penalties into a final score
#'
#' @param candidates Data frame with `component_id`, `mf`, `ri_penalty` and
#'   `element_penalty`. Missing penalties count as 0.
#'
#' @return `candidates` ordered by component (first-appearance order) and
#'   descending `final`, with `final = mf - ri_penalty - element_penalty` and
#'   `final_rank` (1 is best within the component).
#'
#' @keywords internal
.score_candidates <- function(candidates) {
  out <- tibble::as_tibble(candidates)
  out$final <- out$mf -
    dplyr_coalesce0(out$ri_penalty) -
    dplyr_coalesce0(out$element_penalty)
  out <- out[
    order(match(out$component_id, unique(out$component_id)), -out$final),
  ]
  out$final_rank <- as.integer(stats::ave(
    seq_len(nrow(out)),
    out$component_id,
    FUN = seq_along
  ))
  out
}

dplyr_coalesce0 <- function(x) {
  x[is.na(x)] <- 0
  x
}
