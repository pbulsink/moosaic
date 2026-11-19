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
  if (!inherits(info, "moosaic_sample")) {
    .moosaic_abort(
      "{.arg info} must come from {.fn sample_info}.",
      class = "bad_argument"
    )
  }
  exp <- read_experiment(ms_file, fid_file)
  if (verbose) {
    .moosaic_inform(c(
      "Read experiment from {.file {ms_file}} and {.file {fid_file}}.",
      "MS chromatogram: {round(min(exp$ms$rt), 1)} to {round(max(exp$ms$rt), 1)} min @ {round(1/(mean(diff(exp$ms$rt))*60), 1)} Hz.",
      "MS scan range of {min(exp$ms$data[,2])} to {max(exp$ms$data[,2])}.",
      "FID chromatogram: {round(min(exp$fid$rt), 1)} to {round(max(exp$fid$rt), 1)} min @ {round(1/(mean(diff(exp$fid$rt))*60), 1)} Hz.",
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
      "Found {length(result$components)} components after deconvolution.",
    ))
  }
  result$alignment <- exp$alignment
  result <- identify_components(result, ri_cal = ri_cal)
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
