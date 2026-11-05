#' Resolve a search function from its option value
#'
#' @param type One of `"identity"`, `"simple"`, `"hybrid"`, `"neutral_loss"`.
#' @param call Call environment for errors.
#'
#' @return The matching `mspepsearchr` function.
#'
#' @keywords internal
.search_fn <- function(type, call = rlang::caller_env()) {
  nm <- c(
    identity = "IdentitySearchEiNormal",
    simple = "SimilaritySearchEiSimple",
    hybrid = "SimilaritySearchEiHybrid",
    neutral_loss = "SimilaritySearchEiNeutralLoss"
  )
  if (!is.character(type) || length(type) != 1L || !type %in% names(nm)) {
    .moosaic_abort(
      "Unknown search function {.val {type}}; use one of {.val {names(nm)}}.",
      class = "bad_argument",
      call = call
    )
  }
  if (!requireNamespace("mspepsearchr", quietly = TRUE)) {
    .moosaic_abort(
      "Package {.pkg mspepsearchr} is required for library searching.",
      class = "missing_package",
      call = call
    )
  }
  getExportedValue("mspepsearchr", nm[[type]])
}

#' Run a library search
#'
#' @param queries List of query lists (see `.component_to_query()`).
#' @param call Call environment for errors.
#'
#' @return The `mspepsearchr` result: one data frame per query, each with an
#'   `unknown_name` attribute. Library paths, search function, hit count,
#'   threads and RI column type come from the `moosaic.*` options.
#'
#' @keywords internal
.run_mspepsearch <- function(queries, call = rlang::caller_env()) {
  lib <- unlist(.get_moosaic_option("library_path"))
  if (length(lib) == 0L) {
    .moosaic_abort(
      "No spectral library set; call {.fn specify_library} first.",
      class = "missing_library",
      call = call
    )
  }
  fn <- .search_fn(.get_moosaic_option("search_function"))
  ri_type <- .get_moosaic_option("ri_column_type")
  ri_type <- switch(
    ri_type,
    "semi-standard non-polar" = "semistdnp",
    "standard non-polar" = "stdnp",
    ri_type
  )
  fn(
    spectra = queries,
    libraries = lib,
    n_hits = .get_moosaic_option("search_hits"),
    n_threads = .get_moosaic_option("search_threads"),
    ri_column_type = ri_type
  )
}
