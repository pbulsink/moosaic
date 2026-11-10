test_that(".report_path() builds the default file name from project and sample", {
  info <- list(project_code = "P123", sample_id = "S9")
  expect_equal(.report_path(info, "xlsx"), "P123_S9_GC-MS-FID.xlsx")
  expect_equal(.report_path(info, "pdf"), "P123_S9_GC-MS-FID.pdf")
})

test_that(".check_report_path() accepts NULL or a single string", {
  expect_invisible(.check_report_path(NULL))
  expect_null(.check_report_path("out.xlsx"))
})

test_that(".check_report_path() rejects other values", {
  for (bad in list(c("a", "b"), NA_character_, 1, character())) {
    expect_error(.check_report_path(bad), class = "moosaic-error-bad_argument")
  }
})
