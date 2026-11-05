test_that("sample_info() stores metadata with defaults", {
  info <- sample_info("S1", analyst = c("a", "b"), report_date = "2026-01-02")
  expect_s3_class(info, "moosaic_sample")
  expect_equal(info$sample_id, "S1")
  expect_equal(info$analyst, "a/b")
  expect_equal(info$density, 1)
  expect_equal(info$dilution, 1)
  expect_equal(info$methanol_wt_pct, 0)
  expect_equal(info$report_date, as.Date("2026-01-02"))
})

test_that("sample_info() validates its arguments", {
  expect_error(sample_info(1), class = "moosaic-error-bad_argument")
  expect_error(
    sample_info("S1", density = 0),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    sample_info("S1", dilution = -1),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    sample_info("S1", methanol_wt_pct = 101),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    sample_info("S1", water_wt_pct = NA_real_),
    class = "moosaic-error-bad_argument"
  )
})
