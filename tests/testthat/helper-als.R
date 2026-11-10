als_fixture <- function(rank = 2, ...) {
  d <- make_lowrank(rank, ...)
  rownames(d$D) <- NULL
  colnames(d$D) <- as.character(seq_len(ncol(d$D)) + 34)
  d$C0 <- .normalize_columns(d$C + 0.05)
  d$S0 <- .build_s0(d$D, rank)
  d
}
