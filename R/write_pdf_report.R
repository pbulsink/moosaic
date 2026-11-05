#' Write the PDF report
#'
#' Renders the bundled Quarto template (`inst/report/report.qmd`) with the
#' same content as [write_excel_report()], minus the analyst-only QC columns.
#' Needs the quarto package, the Quarto CLI and LaTeX.
#'
#' @param x A `moosaic_result` after [quantify()] (and optionally
#'   [summarize_report()], which is run if needed).
#' @param path Output `.pdf` path; `NULL` gives
#'   `"{project_code}_{sample_id}_GC-MS-FID.pdf"` in the working directory.
#'
#' @return `path`, invisibly.
#'
#' @details The template is copied to a temporary directory and rendered
#'   there, so the package directory is never written to.
#'
#' @examples
#' \dontrun{
#' write_pdf_report(summarize_report(quantified), "report.pdf")
#' }
#'
#' @export
write_pdf_report <- function(x, path = NULL) {
  call <- rlang::current_env()
  rlang::check_installed("quarto", call = call)
  .require_quantified(x, call = call)
  .check_report_path(path, call)
  if (is.null(x$summary)) {
    x <- summarize_report(x)
  }
  path <- path %||% .report_path(x$quant$info, "pdf")
  template <- system.file("report", "report.qmd", package = "moosaic")
  if (!nzchar(template)) {
    .moosaic_abort(
      "Report template not found in the installed package.",
      class = "template_not_found",
      call = call
    )
  }
  work <- tempfile("moosaic-report-")
  dir.create(work)
  on.exit(unlink(work, recursive = TRUE), add = TRUE)
  input <- file.path(work, "report.qmd")
  file.copy(template, input)
  rds <- file.path(work, "result.rds")
  saveRDS(x, rds)
  quarto::quarto_render(
    input = input,
    output_file = basename(path),
    execute_params = list(result_rds = rds),
    quiet = TRUE
  )
  file.copy(file.path(work, basename(path)), path, overwrite = TRUE)
  invisible(path)
}
