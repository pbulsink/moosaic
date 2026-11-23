#' Process a sample from raw files to a quantified result
#'
#' Runs the whole pipeline: [read_experiment()], [align_detectors()], a raw
#' FID baseline check, [deconvolve_run()], [identify_components()],
#' [quantify()] and (by default) [summarize_report()].
#'
#' @param ms_file,fid_file Paths to the ChemStation MS (`.ms`) and FID (`.ch`)
#'   files.
#' @param info Sample metadata from [sample_info()].
#' @param ri_cal RI calibration; see [identify_components()].
#' @param style,reference_peak Quantification options; see [quantify()].
#' @param include_solvents,summarize Whether to include solvent peaks in the
#'   summary, and whether to run [summarize_report()] at all.
#' @param verbose Whether to print detailed information about the processing steps.
#'
#' @details Validates function arguments and configured processing options,
#'   including the spectral search library, before reading or processing data.
#'
#' @return A `moosaic_result` with `components`, `windows`, `identifications`,
#'   `alignment`, `peaks`, `quant` and (if `summarize`) `summary`. Pass it to
#'   [total_compound_table()], [write_excel_report()] or [write_pdf_report()].
#'
#' @examples
#' \dontrun{
#' res <- process_sample("run.ms", "run.ch", sample_info("S1", density = 0.85))
#' write_excel_report(res)
#' }
#'
#' @export
process_sample <- function(
  ms_file,
  fid_file,
  info,
  ri_cal = NULL,
  style = NULL,
  reference_peak = NULL,
  include_solvents = FALSE,
  summarize = TRUE,
  verbose = TRUE
) {
  call <- rlang::current_env()
  if (!inherits(info, "moosaic_sample")) {
    .moosaic_abort(
      "{.arg info} must come from {.fn sample_info}.",
      class = "bad_argument",
      call = call
    )
  }
  .validate_process_sample_options(
    ri_cal = ri_cal,
    style = style,
    reference_peak = reference_peak,
    include_solvents = include_solvents,
    summarize = summarize,
    verbose = verbose,
    call = call
  )

  exp <- read_experiment(ms_file, fid_file)
  if (verbose) {
    .moosaic_inform(c(
      "Read experiment from {.file {ms_file}} and {.file {fid_file}}.",
      "MS chromatogram: {round(min(exp$ms$rt), 1)} to {round(max(exp$ms$rt), 1)} min @ {round(1/(mean(diff(exp$ms$rt))*60), 1)} Hz.",
      "MS scan range of {min(exp$ms$data[,2])} to {max(exp$ms$data[,2])}.",
      "FID chromatogram: {round(min(exp$fid$rt), 1)} to {round(max(exp$fid$rt), 1)} min @ {round(1/(mean(diff(exp$fid$rt))*60), 1)} Hz."
    ))
  }
  exp <- align_detectors(exp)
  if (verbose) {
    .moosaic_inform(c(
      "Aligned detectors using {exp$alignment$engine} correlation.",
      "Alignment found {round(exp$alignment$delay, 5)} minute difference between detectors."
    ))
  }
  baselinecheck <- .check_fid_baseline(exp$fid) # Todo: poorly resolved samples (like the diesel) have elevated/nonlinear baseline but are acceptable.
  if (verbose) {
    .moosaic_inform(c(
      "FID baseline check: {baselinecheck}", #todo: provide more detailed information about the baseline check result
      "Starting deconvolution of MS data to peaks."
    ))
  }
  result <- deconvolve_run(exp, verbose = verbose) # Todo: turn on deconvolution progress bar if verbose
  if (verbose) {
    .moosaic_inform(c(
      "Found {length(result$components)} components after deconvolution."
    ))
  }
  result$alignment <- exp$alignment
  result <- identify_components(result, ri_cal = ri_cal, verbose = verbose)
  if (verbose) {
    .moosaic_inform(c(
      "Identified components ..."
    ))
  }
  result <- quantify(
    result,
    info,
    style = style,
    reference_peak = reference_peak
  )
  if (summarize) {
    if (verbose) {
      .moosaic_inform("Summarizing report to file ...")
    }
    result <- summarize_report(result, include_solvents = include_solvents)
  }
  result
}

#' Validate process_sample() arguments and processing options
#'
#' @param ri_cal,style,reference_peak,include_solvents,summarize,verbose
#'   Arguments passed to [process_sample()].
#' @param call Call environment for errors.
#'
#' @return `NULL`, invisibly. Aborts when an argument or option is invalid.
#' @keywords internal
.validate_process_sample_options <- function(
  ri_cal,
  style,
  reference_peak,
  include_solvents,
  summarize,
  verbose,
  call = rlang::caller_env()
) {
  for (arg in c("include_solvents", "summarize", "verbose")) {
    value <- get(arg)
    if (!rlang::is_bool(value)) {
      .moosaic_abort(
        "{.fn process_sample}: {.arg {arg}} must be TRUE or FALSE.",
        class = "bad_argument",
        call = call
      )
    }
  }

  resolved_style <- rlang::arg_match0(
    style %||% .get_moosaic_option("quant_style"),
    c("internal", "slope", "slope_intercept", "quadratic"),
    arg_nm = "style",
    error_call = call
  )

  if (
    resolved_style == "internal" &&
      !is.null(reference_peak) &&
      (!is.character(reference_peak) ||
        length(reference_peak) != 1L ||
        is.na(reference_peak) ||
        !nzchar(reference_peak))
  ) {
    .moosaic_abort(
      "{.fn process_sample}: {.arg reference_peak} must be NULL or one non-empty component id.",
      class = "bad_argument",
      call = call
    )
  }

  cal <- .resolve_ri_cal(ri_cal)
  if (
    !is.null(cal) &&
      (!is.data.frame(cal) ||
        !all(c("rt", "ri") %in% names(cal)) ||
        nrow(cal) < 2L ||
        !is.numeric(cal$rt) ||
        !is.numeric(cal$ri) ||
        anyNA(cal$rt) ||
        anyNA(cal$ri) ||
        any(diff(cal$rt) <= 0) ||
        any(diff(cal$ri) <= 0))
  ) {
    .moosaic_abort(
      "{.arg ri_cal} must contain at least two rows with strictly increasing numeric {.field rt} and {.field ri}.",
      class = "bad_calibration",
      call = call
    )
  }

  libraries <- .get_moosaic_option("library_path")
  if (is.null(libraries)) {
    .moosaic_abort(
      "No spectral library set; call {.fn specify_library} first.",
      class = "missing_library",
      call = call
    )
  }
  if (!is.character(libraries) && !is.list(libraries)) {
    .moosaic_abort(
      "The {.val moosaic.library_path} option must be a character vector or list of library directories.",
      class = "bad_argument",
      call = call
    )
  }
  if (
    is.list(libraries) &&
      any(!vapply(libraries, is.character, logical(1)))
  ) {
    .moosaic_abort(
      "The {.val moosaic.library_path} option must contain only character paths.",
      class = "bad_argument",
      call = call
    )
  }
  libraries <- unlist(libraries, use.names = FALSE)
  if (
    !is.character(libraries) ||
      length(libraries) == 0L ||
      anyNA(libraries) ||
      any(!nzchar(libraries))
  ) {
    .moosaic_abort(
      "No spectral library set; call {.fn specify_library} first.",
      class = "missing_library",
      call = call
    )
  }
  missing_libraries <- libraries[!dir.exists(libraries)]
  if (length(missing_libraries) > 0L) {
    .moosaic_abort(
      "Spectral library path {.path {missing_libraries[[1]]}} does not exist.",
      class = "missing_path",
      call = call
    )
  }

  .search_fn(.get_moosaic_option("search_function"), call = call)
  rlang::arg_match0(
    .get_moosaic_option("ri_column_type"),
    c("semi-standard non-polar", "standard non-polar"),
    arg_nm = "ri_column_type",
    error_call = call
  )
  for (option in c("search_hits", "search_threads")) {
    value <- .get_moosaic_option(option)
    if (
      !is.integer(value) || length(value) != 1L || is.na(value) || value <= 0L
    ) {
      .moosaic_abort(
        "The {.val moosaic.{option}} option must be a positive integer.",
        class = "bad_argument",
        call = call
      )
    }
  }
  min_match_factor <- .get_moosaic_option("min_match_factor")
  if (
    !is.numeric(min_match_factor) ||
      length(min_match_factor) != 1L ||
      !is.finite(min_match_factor) ||
      min_match_factor < 0 ||
      min_match_factor > 999 ||
      min_match_factor != round(min_match_factor)
  ) {
    .moosaic_abort(
      "The {.val moosaic.min_match_factor} option must be an integer from 0 to 999.",
      class = "bad_argument",
      call = call
    )
  }

  check_number <- function(option, valid, requirement) {
    value <- .get_moosaic_option(option)
    if (
      !is.numeric(value) || length(value) != 1L || is.na(value) || !valid(value)
    ) {
      .moosaic_abort(
        "The {.val moosaic.{option}} option must be {requirement}.",
        class = "bad_argument",
        call = call
      )
    }
  }
  check_bool <- function(option) {
    if (!rlang::is_bool(.get_moosaic_option(option))) {
      .moosaic_abort(
        "The {.val moosaic.{option}} option must be TRUE or FALSE.",
        class = "bad_argument",
        call = call
      )
    }
  }

  align_engine <- .get_moosaic_option("align_engine")
  if (
    !is.character(align_engine) ||
      length(align_engine) != 1L ||
      is.na(align_engine) ||
      !align_engine %in% c("xcorr", "gcalignr")
  ) {
    .moosaic_abort(
      "The {.val moosaic.align_engine} option must be {.val xcorr} or {.val gcalignr}.",
      class = "unknown_engine",
      call = call
    )
  }
  check_number(
    "max_delay",
    \(x) is.finite(x) && x > 0,
    "a finite positive number"
  )
  check_number(
    "align_step",
    \(x) is.finite(x) && x > 0,
    "a finite positive number"
  )
  check_number("mz_min", is.finite, "a finite number")
  check_number("mz_max", is.finite, "a finite number")
  check_number("mz_bin", \(x) is.finite(x) && x > 0, "a finite positive number")
  if (.get_moosaic_option("mz_min") >= .get_moosaic_option("mz_max")) {
    .moosaic_abort(
      "The {.val moosaic.mz_min} option must be less than {.val moosaic.mz_max}.",
      class = "bad_argument",
      call = call
    )
  }

  check_number(
    "fid_smooth_window",
    \(x) is.finite(x) && x >= 3 && x %% 2 == 1 && x == round(x),
    "an odd integer of at least 3"
  )
  baseline_method <- .get_moosaic_option("fid_baseline_method")
  if (
    !is.character(baseline_method) ||
      length(baseline_method) != 1L ||
      is.na(baseline_method) ||
      !baseline_method %in% c("rolling_min", "none")
  ) {
    .moosaic_abort(
      "The {.val moosaic.fid_baseline_method} option must be {.val rolling_min} or {.val none}.",
      class = "bad_argument",
      call = call
    )
  }
  check_number(
    "peak_min_height_snr",
    \(x) is.finite(x) && x > 0,
    "a finite positive number"
  )
  for (option in c("window_padding", "window_merge_gap")) {
    check_number(
      option,
      \(x) is.finite(x) && x >= 0,
      "a finite non-negative number"
    )
  }
  check_number("window_max_width", \(x) x > 0, "a positive number or Inf")
  check_number(
    "window_max_peaks",
    \(x) x > 0 && (is.infinite(x) || x == round(x)),
    "a positive whole number or Inf"
  )
  for (option in c(
    "min_scans_per_window",
    "rank_max",
    "pa_iterations",
    "als_maxiter"
  )) {
    check_number(
      option,
      \(x) is.finite(x) && x >= 1 && x == round(x),
      "a positive whole number"
    )
  }

  rank_methods <- .get_moosaic_option("rank_methods")
  allowed_methods <- c("fid", "svd", "bic", "pfr", "pa")
  if (
    !is.character(rank_methods) ||
      length(rank_methods) == 0L ||
      anyNA(rank_methods) ||
      length(setdiff(rank_methods, allowed_methods)) > 0L
  ) {
    .moosaic_abort(
      "The {.val moosaic.rank_methods} option must contain values from {.val {allowed_methods}}.",
      class = "unknown_method",
      call = call
    )
  }
  check_number(
    "svd_var_threshold",
    \(x) is.finite(x) && x > 0 && x <= 1,
    "a number in (0, 1]"
  )
  check_number(
    "pfr_cutoff",
    \(x) is.finite(x) && x > 0 && x < 1,
    "a number in (0, 1)"
  )
  check_number(
    "als_thresh",
    \(x) is.finite(x) && x > 0,
    "a finite positive number"
  )
  for (option in c("background_component", "als_unimodal", "ri_extrapolate")) {
    check_bool(option)
  }

  for (option in c(
    "ri_grace",
    "ri_penalty_per_unit",
    "disallowed_element_penalty"
  )) {
    check_number(
      option,
      \(x) is.finite(x) && x >= 0,
      "a finite non-negative number"
    )
  }
  penalties <- .get_moosaic_option("element_penalties")
  if (
    !is.numeric(penalties) ||
      is.null(names(penalties)) ||
      any(!nzchar(names(penalties))) ||
      anyDuplicated(names(penalties)) ||
      anyNA(penalties) ||
      any(!is.finite(penalties)) ||
      any(penalties < 0) ||
      length(setdiff(names(penalties), .element_symbols)) > 0L
  ) {
    .moosaic_abort(
      "The {.val moosaic.element_penalties} option must be a named vector of finite non-negative numbers.",
      class = "bad_argument",
      call = call
    )
  }
  allowed_elements <- .get_moosaic_option("allowed_elements")
  if (
    !is.character(allowed_elements) ||
      anyNA(allowed_elements) ||
      length(setdiff(allowed_elements, .element_symbols)) > 0L
  ) {
    .moosaic_abort(
      "The {.val moosaic.allowed_elements} option must be a character vector without missing values.",
      class = "bad_argument",
      call = call
    )
  }

  invisible(NULL)
}
