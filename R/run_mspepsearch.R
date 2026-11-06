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
  # mspepsearchr accepts at most one library besides mainlib/replib per call,
  # so each extra library gets its own search and the hits are merged.
  core <- tolower(basename(lib)) %in% c("mainlib", "replib")
  batches <- c(
    if (any(core)) list(lib[core]),
    lapply(lib[!core], \(x) x)
  )
  per_batch <- lapply(batches, \(libs) {
    fn(
      spectra = queries,
      libraries = libs,
      n_hits = .get_moosaic_option("search_hits"),
      n_threads = min(.get_moosaic_option("search_threads"), length(queries)),
      ri_column_type = ri_type
    )
  })
  if (length(per_batch) == 1L) {
    return(per_batch[[1]])
  }
  .merge_search_batches(per_batch)
}

#' Merge per-library search results query by query
#'
#' @param batches List of `mspepsearchr` results (one data frame per query,
#'   same query order).
#'
#' @return One list of data frames, rows stacked per query, best match factor
#'   first, with the `unknown_name` attribute kept.
#'
#' @keywords internal
.merge_search_batches <- function(batches) {
  lapply(seq_along(batches[[1]]), \(i) {
    parts <- lapply(batches, \(b) b[[i]])
    parts <- parts[vapply(parts, \(x) is.data.frame(x) && nrow(x) > 0L, TRUE)]
    nm <- attr(batches[[1]][[i]], "unknown_name")
    out <- if (length(parts) == 0L) {
      batches[[1]][[i]]
    } else {
      df <- do.call(rbind, parts)
      mf <- intersect(c("mf", "MF", "match_factor"), names(df))
      if (length(mf) > 0L) {
        df <- df[order(-df[[mf[1]]]), , drop = FALSE]
        rownames(df) <- NULL
      }
      df
    }
    attr(out, "unknown_name") <- nm
    out
  })
}
