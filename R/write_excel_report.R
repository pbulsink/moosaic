#' Write the Excel report
#'
#' Writes a workbook with a "Total Compound Report" sheet (sample header and
#' [total_compound_table()]) and a "Summary Report" sheet (families, elements
#' and notes).
#'
#' @param x A `moosaic_result` after [quantify()] (and optionally
#'   [summarize_report()], which is run if needed).
#' @param path Output `.xlsx` path; `NULL` gives
#'   `"{project_code}_{sample_id}_GC-MS-FID.xlsx"` in the working directory.
#'
#' @return `path`, invisibly. Sheet names are truncated to Excel's 31
#'   characters and stripped of characters Excel forbids.
#'
#' @examples
#' \dontrun{
#' write_excel_report(summarize_report(quantified), tempfile(fileext = ".xlsx"))
#' }
#'
#' @export
write_excel_report <- function(x, path = NULL) {
  call <- rlang::current_env()
  .require_quantified(x, call = call)
  .check_report_path(path, call)
  if (is.null(x$summary)) {
    x <- summarize_report(x)
  }
  info <- x$quant$info
  s <- x$summary
  t <- s$totals
  q <- s$qc
  path <- path %||% .report_path(info, "xlsx")

  wb <- openxlsx::createWorkbook()
  date_style <- openxlsx::createStyle(numFmt = "yyyy-mm-dd")
  bold <- openxlsx::createStyle(textDecoration = "bold")
  id <- gsub("[][:*?/\\\\]", "_", info$sample_id, perl = TRUE)
  s1 <- paste(substr(id, 1, 9), "Total Compound Report")
  s2 <- paste(substr(id, 1, 16), "Summary Report")

  openxlsx::addWorksheet(wb, s1)
  meta <- data.frame(
    A = c("Sample ID", "Sample Name", "Project Code", "Report Date", "Analyst"),
    B = c(
      info$sample_id,
      info$sample_name,
      info$project_code,
      NA,
      info$analyst
    ),
    C = c("Density", "Methanol", "Water", "GC Recovery", "Total:"),
    D = c(
      info$density,
      info$methanol_wt_pct,
      info$water_wt_pct,
      round(t$gc_recovery, 1),
      round(t$total, 1)
    ),
    E = c("g/mL", "wt. %", "wt. %", "wt. %", "wt. %"),
    F = c(
      "Aligned Peaks",
      "Unique Peaks",
      "Total Peaks",
      "Interpolated Peaks",
      "MS/FID Offset Time"
    ),
    G = c(
      q$aligned_peaks,
      q$unique_peaks,
      q$total_peaks,
      q$interpolated_peaks,
      round(q$ms_fid_offset, 3)
    ),
    H = c(NA, NA, NA, NA, "min"),
    stringsAsFactors = FALSE
  )
  openxlsx::writeData(wb, s1, meta, colNames = FALSE)
  openxlsx::writeData(wb, s1, info$report_date, startRow = 4, startCol = 2)
  openxlsx::addStyle(wb, s1, date_style, rows = 4, cols = 2)
  tbl <- total_compound_table(x)
  openxlsx::writeData(wb, s1, tbl, startRow = 6)
  openxlsx::addStyle(
    wb,
    s1,
    bold,
    rows = 6,
    cols = seq_len(ncol(tbl)),
    gridExpand = TRUE
  )
  openxlsx::setColWidths(wb, s1, cols = seq_len(ncol(tbl)), widths = "auto")

  openxlsx::addWorksheet(wb, s2)
  head_block <- data.frame(
    A = c(
      "Sample ID",
      "Sample Name",
      "Project Code",
      "Report Date",
      "Analyst",
      "Density (g/mL)"
    ),
    B = c(
      info$sample_id,
      info$sample_name,
      info$project_code,
      NA,
      info$analyst,
      info$density
    ),
    stringsAsFactors = FALSE
  )
  openxlsx::writeData(wb, s2, head_block, colNames = FALSE)
  openxlsx::writeData(wb, s2, info$report_date, startRow = 4, startCol = 2)
  openxlsx::addStyle(wb, s2, date_style, rows = 4, cols = 2)
  fam <- rbind(
    data.frame(a = s$families$compound_type, b = round(s$families$wt_pct, 1)),
    data.frame(
      a = c("Methanol (external)", "Water", "TOTAL"),
      b = round(c(t$methanol, t$water, t$total), 1)
    )
  )
  names(fam) <- c("Compound Type", "Total Amount (wt. %)")
  openxlsx::writeData(wb, s2, fam, startRow = 7)
  el <- data.frame(
    Element = c(s$elements$element, "Sum"),
    `Calculated wt. %` = round(c(s$elements$wt_pct, t$element_sum), 2),
    check.names = FALSE
  )
  openxlsx::writeData(wb, s2, el, startRow = 7, startCol = 3)
  openxlsx::writeData(
    wb,
    s2,
    c("NOTE:", .element_note()),
    startRow = 7,
    startCol = 6,
    colNames = FALSE
  )
  openxlsx::addStyle(wb, s2, bold, rows = 7, cols = 1:4, gridExpand = TRUE)
  notes_row <- 7 + nrow(fam) + 2
  openxlsx::writeData(wb, s2, "NOTES:", startRow = notes_row, startCol = 1)
  openxlsx::writeData(
    wb,
    s2,
    paste0(seq_along(.summary_notes()), ". ", .summary_notes()),
    startRow = notes_row + 1,
    startCol = 1,
    colNames = FALSE
  )
  openxlsx::setColWidths(wb, s2, cols = 1:6, widths = "auto")

  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}
