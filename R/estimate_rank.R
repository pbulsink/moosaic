#' Estimate the number of components in a window
#'
#' Combines several independent estimates of the chemical rank of a window's
#' data matrix by majority vote.
#'
#' @param D Numeric matrix without missing values, scans x m/z (see
#'   [extract_ms_matrix()]).
#' @param fid Optional list with numeric `rt` and `intensity`, one value per
#'   row of `D` (see `.extract_fid_window()`). Required when `"fid"` is in
#'   `methods`.
#' @param methods Character vector, any of `"fid"`, `"svd"`, `"bic"`, `"pa"`.
#'   `NULL` uses the `moosaic.rank_methods` option.
#' @param max_rank Positive integer upper limit. `NULL` uses the
#'   `moosaic.rank_max` option. Reduced to `min(dim(D))` with a message if
#'   larger.
#'
#' @return A list with `rank` (integer, at least 1), `confidence` (share of
#'   usable votes equal to `rank`, in 0 to 1) and `votes` (named integer
#'   vector, one entry per method, `NA` when a method could not vote).
#'
#' @details Parallel analysis (`"pa"`) is skipped when at least two of the
#'   other methods gave a usable vote and all of them agree; `votes` then has
#'   no `pa` entry. Votes above `max_rank` are capped. If the consensus is 0
#'   (no method finds signal), `rank` is 1, `confidence` is the share of
#'   votes equal to 1, and a message of class `no_signal` is emitted. The
#'   `"svd"`, `"bic"` and `"pa"` methods read their settings from
#'   `moosaic.svd_var_threshold` and `moosaic.pa_iterations`. `"pa"` uses
#'   random permutations; call [set.seed()] first for reproducible results.
#'   The optional background component is added later, not here.
#'
#' @examples
#' set.seed(2615)
#' scan <- 1:40
#' C <- cbind(exp(-0.5 * ((scan - 12) / 3)^2), exp(-0.5 * ((scan - 22) / 3)^2))
#' S <- cbind(exp(-0.5 * ((1:30 - 8) / 3)^2), exp(-0.5 * ((1:30 - 20) / 3)^2))
#' D <- 100 * C %*% t(S)
#' estimate_rank(D, list(rt = scan, intensity = rowSums(C)))
#'
#' @export
estimate_rank <- function(D, fid = NULL, methods = NULL, max_rank = NULL) {
  call <- rlang::current_env()
  all_methods <- c("fid", "svd", "bic", "pa")
  if (!is.matrix(D) || !is.numeric(D) || anyNA(D) || any(dim(D) < 1L)) {
    .moosaic_abort(
      "{.arg D} must be a non-empty numeric matrix without missing values.",
      class = "bad_argument",
      call = call
    )
  }
  methods <- methods %||% .get_moosaic_option("rank_methods")
  bad <- setdiff(methods, all_methods)
  if (length(bad) > 0L) {
    .moosaic_abort(
      "Unknown rank method: {.val {bad}}. Valid methods: {.val {all_methods}}.",
      class = "unknown_method",
      call = call
    )
  }
  if ("fid" %in% methods) {
    if (is.null(fid)) {
      .moosaic_abort(
        "Method {.val fid} needs {.arg fid}.",
        class = "missing_fid",
        call = call
      )
    }
    if (
      !is.list(fid) ||
        length(fid$intensity) != nrow(D) ||
        length(fid$rt) != nrow(D)
    ) {
      .moosaic_abort(
        "{.arg fid} must have {nrow(D)} values in {.field rt} and {.field intensity}, one per row of {.arg D}.",
        class = "bad_argument",
        call = call
      )
    }
  }
  max_rank <- max_rank %||% .get_moosaic_option("rank_max")
  if (
    !is.numeric(max_rank) ||
      length(max_rank) != 1L ||
      is.na(max_rank) ||
      max_rank < 1 ||
      max_rank != round(max_rank)
  ) {
    .moosaic_abort(
      "{.arg max_rank} must be a positive whole number.",
      class = "bad_argument",
      call = call
    )
  }
  limit <- min(dim(D))
  if (max_rank > limit) {
    .moosaic_inform(
      "{.fn estimate_rank}: {.arg max_rank} ({max_rank}) reduced to {limit}, the smallest dimension of {.arg D}.",
      class = "max_rank_reduced"
    )
    max_rank <- limit
  }

  run_method <- \(m) {
    switch(
      m,
      fid = .rank_fid(fid, call = call),
      svd = .rank_svd(D, .get_moosaic_option("svd_var_threshold"), call = call),
      bic = .rank_bic(D, max_rank),
      pa = .rank_pa(
        D,
        .get_moosaic_option("pa_iterations"),
        max_rank,
        call = call
      )
    )
  }
  cap <- \(v) pmin(v, as.integer(max_rank))

  # Parallel analysis is by far the slowest method, so it only runs when the
  # cheaper methods do not already agree.
  cheap <- setdiff(methods, "pa")
  votes <- cap(vapply(cheap, run_method, integer(1)))
  if ("pa" %in% methods) {
    usable <- votes[!is.na(votes)]
    unanimous <- length(usable) >= 2L && length(unique(usable)) == 1L
    if (!unanimous) {
      votes <- c(votes, pa = cap(run_method("pa")))
    }
  }
  votes <- votes[intersect(methods, names(votes))]

  out <- .consensus_rank(votes, call = call)
  if (out$rank < 1L) {
    .moosaic_inform(
      "{.fn estimate_rank}: no method found signal in the window; using rank 1.",
      class = "no_signal"
    )
    out$rank <- 1L
    out$confidence <- mean(votes[!is.na(votes)] == 1L)
  }
  list(rank = out$rank, confidence = out$confidence, votes = votes)
}
