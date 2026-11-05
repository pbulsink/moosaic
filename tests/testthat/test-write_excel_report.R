test_that("write_excel_report() writes the two report sheets", {
  path <- withr::local_tempfile(fileext = ".xlsx")
  out <- write_excel_report(mk_quantified(), path)
  expect_equal(out, path)
  expect_true(file.exists(path))
  expect_equal(
    openxlsx::getSheetNames(path),
    c("S1 Total Compound Report", "S1 Summary Report")
  )
})

test_that("write_excel_report() puts the compound table below the header block", {
  x <- mk_quantified()
  path <- withr::local_tempfile(fileext = ".xlsx")
  write_excel_report(x, path)
  tbl <- openxlsx::read.xlsx(path, sheet = 1, startRow = 6, sep.names = " ")
  expect_equal(names(tbl), names(total_compound_table(x)))
  expect_equal(nrow(tbl), 4L)
  head <- openxlsx::read.xlsx(path, sheet = 1, rows = 1:5, colNames = FALSE)
  expect_equal(head$X1, c("Sample ID", "Sample Name", "Project Code", "Report Date", "Analyst"))
  expect_equal(head$X2[1], "S1")
})

test_that("write_excel_report() writes family and element summaries", {
  x <- mk_quantified()
  path <- withr::local_tempfile(fileext = ".xlsx")
  write_excel_report(x, path)
  sm <- openxlsx::read.xlsx(path, sheet = 2, startRow = 7, sep.names = " ")
  expect_equal(names(sm)[1:4], c("Compound Type", "Total Amount (wt. %)", "Element", "Calculated wt. %"))
  expect_equal(sm[[1]][1:8], x$summary$families$compound_type)
  expect_equal(sm[[1]][9:11], c("Methanol (external)", "Water", "TOTAL"))
  expect_equal(sm[[3]][6], "Sum")
})

test_that("write_excel_report() names the file from the sample by default", {
  withr::local_dir(withr::local_tempdir())
  out <- write_excel_report(mk_quantified())
  expect_equal(out, "P9_S1_GC-MS-FID.xlsx")
  expect_true(file.exists(out))
})

test_that("write_excel_report() summarises a quantified result on demand", {
  x <- mk_quantified()
  x$summary <- NULL
  path <- withr::local_tempfile(fileext = ".xlsx")
  expect_no_error(write_excel_report(x, path))
})

test_that("write_excel_report() truncates long sheet names and validates path", {
  x <- mk_quantified()
  x$quant$info$sample_id <- strrep("A", 40)
  path <- withr::local_tempfile(fileext = ".xlsx")
  write_excel_report(x, path)
  expect_true(all(nchar(openxlsx::getSheetNames(path)) <= 31))
  expect_error(write_excel_report(x, c("a", "b")), class = "moosaic-error-bad_argument")
  expect_error(write_excel_report(1, path), class = "moosaic-error-bad_argument")
})
