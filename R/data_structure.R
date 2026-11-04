#' Create a new gcms_fid_exp object (internal constructor)
#'
#' Internal function to construct the core data structure.
#' Use [gcms_fid_exp()] or [read_experiment()] to build objects in user code.
#'
#' @param ms List with elements `data` (matrix, rt, tic), `metadata`.
#' @param fid List with elements `rt`, `intensity`, `metadata`.
#' @param alignment List with elements `delay`, `engine`, `score`, `validated`.
#' @param processing List (log of steps and parameters).
#'
#' @return An object of class `gcms_fid_exp`.
#'
#' @keywords internal
.new_gcms_fid_exp <- function(ms, fid, alignment, processing) {
  structure(
    list(
      ms = ms,
      fid = fid,
      alignment = alignment,
      processing = processing
    ),
    class = "gcms_fid_exp"
  )
}

#' Validate a gcms_fid_exp object
#'
#' Internal validation function; aborts if structure is invalid.
#'
#' @param x An object to validate.
#' @param call Call environment for error messages.
#'
#' @return Invisibly, x if valid.
#'
#' @keywords internal
.validate_gcms_fid_exp <- function(x, call = rlang::caller_env()) {
  if (!is.list(x) || !identical(class(x), "gcms_fid_exp")) {
    .moosaic_abort("invalid gcms_fid_exp object", call = call)
  }

  # Check required slots
  if (!all(c("ms", "fid", "alignment", "processing") %in% names(x))) {
    .moosaic_abort(
      "gcms_fid_exp missing required slots",
      class = "bad_structure",
      call = call
    )
  }

  # Validate MS
  ms <- x$ms
  if (!all(c("data", "rt", "tic", "metadata") %in% names(ms))) {
    .moosaic_abort("MS missing required elements", call = call)
  }
  if (!is.numeric(ms$rt) || is.unsorted(ms$rt)) {
    .moosaic_abort(
      "MS rt must be numeric and sorted",
      class = "bad_structure",
      call = call
    )
  }
  if (length(ms$rt) != length(ms$tic)) {
    .moosaic_abort(
      "MS rt and tic length mismatch",
      class = "bad_structure",
      call = call
    )
  }
  if (!all(ms$tic >= 0)) {
    .moosaic_abort("MS tic must be non-negative", call = call)
  }

  # Validate FID
  fid <- x$fid
  if (!all(c("rt", "intensity", "metadata") %in% names(fid))) {
    .moosaic_abort("FID missing required elements", call = call)
  }
  if (!is.numeric(fid$rt) || !is.numeric(fid$intensity)) {
    .moosaic_abort("FID rt and intensity must be numeric", call = call)
  }
  if (length(fid$rt) != length(fid$intensity)) {
    .moosaic_abort("FID rt and intensity length mismatch", call = call)
  }
  if (is.unsorted(fid$rt)) {
    .moosaic_abort(
      "FID rt must be sorted",
      class = "bad_structure",
      call = call
    )
  }

  # Validate alignment
  if (!is.list(x$alignment)) {
    .moosaic_abort("alignment must be a list", call = call)
  }

  invisible(x)
}

#' Create a gcms_fid_exp object from raw data
#'
#' High-level constructor for a GC-FID/MS experiment from MS and FID matrices.
#'
#' @param ms_data Numeric matrix with columns `rt`, `mz`, `intensity` (long format),
#'   or matrix with row scans, column m/z (dense format) with `rt` and `tic` as attributes.
#' @param fid_rt Numeric vector; FID retention times (min).
#' @param fid_intensity Numeric vector; FID intensities (pA).
#' @param ms_metadata List; metadata for MS detector.
#' @param fid_metadata List; metadata for FID detector.
#'
#' @return A `gcms_fid_exp` object.
#'
#' @examples
#' \dontrun{
#'   # From long-format MS data
#'   exp <- gcms_fid_exp(
#'     ms_data = ms_long,  # matrix: rt, mz, intensity
#'     fid_rt = fid$rt,
#'     fid_intensity = fid$intensity,
#'     ms_metadata = list(sample_name = "sample1"),
#'     fid_metadata = list(units = "pA")
#'   )
#' }
#'
#' @export
gcms_fid_exp <- function(
  ms_data,
  fid_rt,
  fid_intensity,
  ms_metadata = list(),
  fid_metadata = list()
) {
  ms <- .standardize_ms(ms_data, call = rlang::caller_env())
  fid <- .standardize_fid(
    list(rt = fid_rt, intensity = fid_intensity),
    call = rlang::caller_env()
  )

  # Add metadata
  ms$metadata <- ms_metadata
  fid$metadata <- fid_metadata

  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )

  .validate_gcms_fid_exp(exp, call = rlang::caller_env())
  exp
}

#' Read a GC-FID/MS experiment from ChemStation files
#'
#' Reads `.ms` and `.ch` files using chromConverter and constructs
#' a validated `gcms_fid_exp` object.
#'
#' @param ms_file Character; path to ChemStation `.ms` file.
#' @param fid_file Character; path to ChemStation `.ch` file.
#'
#' @return A `gcms_fid_exp` object.
#'
#' @examples
#' \dontrun{
#'   exp <- read_experiment("sample.ms", "sample.ch")
#' }
#'
#' @export
read_experiment <- function(ms_file, fid_file) {
  if (!file.exists(ms_file)) {
    .moosaic_abort(
      "MS file {.path {ms_file}} not found",
      class = "file_not_found",
      call = rlang::caller_env()
    )
  }
  if (!file.exists(fid_file)) {
    .moosaic_abort(
      "FID file {.path {fid_file}} not found",
      class = "file_not_found",
      call = rlang::caller_env()
    )
  }

  # Use chromConverter to read
  ms_raw <- chromConverter::read_chemstation_ms(
    ms_file,
    data_format = "long",
    format_out = "matrix"
  )
  fid_raw <- chromConverter::read_chemstation_ch(fid_file, scale = TRUE)

  # Standardize to internal structure
  ms <- .standardize_ms(ms_raw, call = rlang::caller_env())
  fid <- .standardize_fid(fid_raw, call = rlang::caller_env())

  # Extract metadata from attributes
  ms$metadata <- .extract_metadata(ms_raw)
  fid$metadata <- .extract_metadata(fid_raw)

  # Add file sources to metadata
  ms$metadata$source_file <- ms_file
  fid$metadata$source_file <- fid_file

  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list(
      read_experiment = list(ms_file = ms_file, fid_file = fid_file)
    )
  )

  .validate_gcms_fid_exp(exp, call = rlang::caller_env())
  exp
}

#' Extract metadata from a raw data object
#'
#' Pulls attributes into a named list, excluding structural metadata like `dim`.
#'
#' @param x An object with attributes.
#'
#' @return Named list of attributes (excluding `dim`, `dimnames`, `class`).
#'
#' @keywords internal
.extract_metadata <- function(x) {
  atts <- attributes(x)
  exclude <- c("dim", "dimnames", "class", "names")
  keep <- setdiff(names(atts), exclude)
  as.list(atts[keep])
}

#' Standardize MS data to internal structure
#'
#' Converts long-format or dense MS matrices to the internal representation.
#'
#' @param raw MS data from chromConverter or user input.
#' @param call Call environment for errors.
#'
#' @return List with `data`, `rt`, `tic`.
#'
#' @keywords internal
.standardize_ms <- function(raw, call = rlang::caller_env()) {
  # Detect format
  if (is.matrix(raw) || is.data.frame(raw)) {
    # Check if long format (3 columns: rt, mz, intensity) or dense
    if (ncol(raw) == 3) {
      # Long format
      cnames <- tolower(colnames(raw))
      if (!all(c("rt", "mz", "intensity") %in% cnames)) {
        .moosaic_abort(
          "MS matrix must have columns: rt, mz, intensity",
          class = "bad_format",
          call = call
        )
      }
      data <- as.matrix(raw)
      # Extract unique rt values (scans)
      rt_col <- which(tolower(colnames(raw)) == "rt")
      rt <- sort(unique(data[, rt_col]))
      # Compute TIC
      tic <- numeric(length(rt))
      for (i in seq_along(rt)) {
        tic[i] <- sum(data[abs(data[, rt_col] - rt[i]) < 1e-6, 3])
      }
      return(list(data = data, rt = rt, tic = tic))
    } else {
      .moosaic_abort(
        "MS matrix must have 3 columns (rt, mz, intensity)",
        class = "bad_format",
        call = call
      )
    }
  }

  # Check if it's a list (chromConverter format)
  if (is.list(raw)) {
    if (!all(c("MS1", "TIC") %in% names(raw))) {
      .moosaic_abort(
        "MS list must have MS1 and TIC elements",
        class = "bad_format",
        call = call
      )
    }
    return(list(
      data = as.matrix(raw$MS1),
      rt = raw$rt %||% sort(unique(raw$MS1[, 1])),
      tic = raw$TIC[, 2]
    ))
  }

  .moosaic_abort(
    "MS data must be a matrix or list",
    class = "bad_format",
    call = call
  )
}

#' Standardize FID data to internal structure
#'
#' Converts FID matrix/data.frame to the internal representation.
#'
#' @param raw FID data from chromConverter or user input.
#' @param call Call environment for errors.
#'
#' @return List with `rt`, `intensity`.
#'
#' @keywords internal
.standardize_fid <- function(raw, call = rlang::caller_env()) {
  if (is.matrix(raw) || is.data.frame(raw)) {
    if (ncol(raw) != 2) {
      .moosaic_abort(
        "FID matrix must have 2 columns (rt, intensity)",
        class = "bad_format",
        call = call
      )
    }
    return(list(
      rt = as.numeric(raw[, 1]),
      intensity = as.numeric(raw[, 2])
    ))
  }

  if (is.list(raw)) {
    if (!all(c("rt", "intensity") %in% names(raw))) {
      .moosaic_abort(
        "FID list must have rt and intensity elements",
        class = "bad_format",
        call = call
      )
    }
    return(list(
      rt = as.numeric(raw$rt),
      intensity = as.numeric(raw$intensity)
    ))
  }

  .moosaic_abort(
    "FID data must be a matrix or list",
    class = "bad_format",
    call = call
  )
}

#' Check if object is a gcms_fid_exp
#'
#' @param x Object to test.
#'
#' @return Logical.
#'
#' @examples
#' is_gcms_fid_exp(list())  # FALSE
#'
#' @export
is_gcms_fid_exp <- function(x) {
  identical(class(x), "gcms_fid_exp")
}

#' Print a gcms_fid_exp object
#'
#' @param x A `gcms_fid_exp` object.
#' @param ... Additional arguments (unused).
#'
#' @return Invisibly, x.
#'
#' @keywords internal
#' @export
print.gcms_fid_exp <- function(x, ...) {
  cat("GC-FID/MS Experiment\n")
  cat("Sample:", x$ms$metadata$sample_name %||% "unknown", "\n")
  cat("FID points:", length(x$fid$rt), "\n")
  cat("MS scans:", length(x$ms$rt), "\n")
  cat(
    "RT range:",
    sprintf("%.2f", min(x$ms$rt)),
    "–",
    sprintf("%.2f", max(x$ms$rt)),
    "min\n"
  )
  cat("Alignment delay:", x$alignment$delay %||% 0, "min\n")
  cat("Processing steps:", length(x$processing), "\n")

  invisible(x)
}
