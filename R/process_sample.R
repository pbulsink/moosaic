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
  summarize = TRUE
) {
  if (!inherits(info, "moosaic_sample")) {
    .moosaic_abort(
      "{.arg info} must come from {.fn sample_info}.",
      class = "bad_argument"
    )
  }
  exp <- read_experiment(ms_file, fid_file)
  exp <- align_detectors(exp)
  .check_fid_baseline(exp$fid)
  result <- deconvolve_run(exp)
  result$alignment <- exp$alignment
  result <- identify_components(result, ri_cal = ri_cal)
  result <- quantify(
    result,
    info,
    style = style,
    reference_peak = reference_peak
  )
  if (summarize) {
    result <- summarize_report(result, include_solvents = include_solvents)
  }
  result
}
