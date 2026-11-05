
test_that("specify_ri_calibration() aborts on missing file", {
  expect_error(
    specify_ri_calibration("/nonexistent/ONSITE.CAL"),
    class = "moosaic-error-missing_file"
  )
})

