#' Specify library paths for spectral searching
#'
#' Sets `moosaic.library_path` to a list of NIST-format library directory paths.
#' Each path is checked to exist.
#'
#' @param paths Character vector or list of path strings to NIST library directories.
#'
#' @return Invisibly, the new library path setting.
#'
#' @examples
#' \dontrun{
#'   specify_library("C:/NIST23/MSSEARCH/mainlib/")
#'   specify_library(c("C:/NIST23/mainlib/", "C:/NIST23/replib/"))
#' }
#'
#' @export
specify_library <- function(paths) {
  if (!is.character(paths) && !is.list(paths)) {
    .moosaic_abort(
      "{.var paths} must be a character vector or list",
      class = "bad_input",
      call = rlang::caller_env()
    )
  }

  if (is.character(paths)) {
    paths <- as.list(paths)
  }

  # Check each path exists
  for (path in paths) {
    if (!dir.exists(path)) {
      .moosaic_abort(
        "library path {.path {path}} does not exist",
        class = "missing_path",
        call = rlang::caller_env()
      )
    }
  }

  set_moosaic_options(library_path = paths)
  invisible(getOption("moosaic.library_path"))
}

#' Specify RI calibration file
#'
#' Sets `moosaic.ri_calibration_path` and validates the file exists and is readable.
#'
#' @param path Character; path to `.CAL` file.
#'
#' @return Invisibly, the new path setting.
#'
#' @examples
#' \dontrun{
#'   specify_ri_calibration("ONSITE.CAL")
#' }
#'
#' @export
specify_ri_calibration <- function(path) {
  if (!file.exists(path)) {
    .moosaic_abort(
      "RI calibration file {.path {path}} does not exist",
      class = "missing_file",
      call = rlang::caller_env()
    )
  }

  set_moosaic_options(ri_calibration_path = path)
  invisible(getOption("moosaic.ri_calibration_path"))
}

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

#' Specify identification penalties
#'
#' Configures RI and element-based penalties for candidate scoring.
#'
#' @param ri_grace Integer; RI value within this range incurs zero penalty (default from options).
#' @param ri_penalty_per_unit Numeric; penalty per RI unit outside grace range (default from options).
#' @param element_penalties Named numeric vector; penalties for each element (default from options).
#' @param allowed_elements Character vector; elements allowed in formulas (default from options).
#'
#' @return Invisibly, previous option values.
#'
#' @examples
#' \dontrun{
#'   specify_identification_penalties(
#'     ri_grace = 15,
#'     element_penalties = c(N = 50, S = 100)
#'   )
#' }
#'
#' @export
specify_identification_penalties <- function(
  ri_grace = NULL,
  ri_penalty_per_unit = NULL,
  element_penalties = NULL,
  allowed_elements = NULL
) {
  opts <- list()
  if (!is.null(ri_grace)) {
    opts$ri_grace <- ri_grace
  }
  if (!is.null(ri_penalty_per_unit)) {
    opts$ri_penalty_per_unit <- ri_penalty_per_unit
  }
  if (!is.null(element_penalties)) {
    opts$element_penalties <- element_penalties
  }
  if (!is.null(allowed_elements)) {
    opts$allowed_elements <- allowed_elements
  }

  if (length(opts) > 0) {
    do.call(set_moosaic_options, opts)
  }

  invisible(moosaic_options())
}
