#' Specify search parameters
#'
#' Configures library search options: search function, number of hits, threads, and scoring.
#'
#' @param type Character; search function type: `"identity"`, `"simple"`, `"hybrid"`, or `"neutral_loss"`.
#' @param hits Integer; number of hits to return (default from options).
#' @param threads Integer; number of threads for parallel search (default from options).
#' @param ri_column_type Character; RI column type string (must be recognized by mspepsearchr).
#' @param min_match_factor Integer; minimum match factor to report (default from options).
#'
#' @return Invisibly, previous option values.
#'
#' @examples
#' \dontrun{
#'   specify_search_params(
#'     type = "hybrid",
#'     hits = 20L,
#'     threads = 4L,
#'     min_match_factor = 700
#'   )
#' }
#'
#' @export
specify_search_params <- function(
  type = NULL,
  hits = NULL,
  threads = NULL,
  ri_column_type = NULL,
  min_match_factor = NULL
) {
  # Validate type if provided
  if (!is.null(type)) {
    type <- rlang::arg_match(
      type,
      c("identity", "simple", "hybrid", "neutral_loss")
    )
  }

  # Validate hits if provided
  if (!is.null(hits)) {
    if (!is.integer(hits) || length(hits) != 1 || hits <= 0) {
      .moosaic_abort(
        "{.var hits} must be a positive integer",
        class = "bad_input",
        call = rlang::caller_env()
      )
    }
  }

  # Validate threads if provided
  if (!is.null(threads)) {
    if (!is.integer(threads) || length(threads) != 1 || threads <= 0) {
      .moosaic_abort(
        "{.var threads} must be a positive integer",
        class = "bad_input",
        call = rlang::caller_env()
      )
    }
  }

  # Build options list
  opts <- list()
  if (!is.null(type)) {
    opts$search_function <- type
  }
  if (!is.null(hits)) {
    opts$search_hits <- hits
  }
  if (!is.null(threads)) {
    opts$search_threads <- threads
  }
  if (!is.null(ri_column_type)) {
    opts$ri_column_type <- ri_column_type
  }
  if (!is.null(min_match_factor)) {
    opts$min_match_factor <- min_match_factor
  }

  if (length(opts) > 0) {
    do.call(set_moosaic_options, opts)
  }

  invisible(moosaic_options())
}
