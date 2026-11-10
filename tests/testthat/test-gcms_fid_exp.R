long_ms <- function() {
  m <- cbind(
    rt = c(1, 1, 2, 2),
    mz = c(40, 41, 40, 41),
    intensity = c(1, 2, 3, 4)
  )
  m
}

test_that("gcms_fid_exp() builds a validated object with TIC and metadata", {
  exp <- gcms_fid_exp(
    long_ms(),
    fid_rt = c(1, 1.5, 2),
    fid_intensity = c(5, 6, 7),
    ms_metadata = list(a = 1),
    fid_metadata = list(b = 2)
  )
  expect_s3_class(exp, "gcms_fid_exp")
  expect_equal(exp$ms$rt, c(1, 2))
  expect_equal(exp$ms$tic, c(3, 7))
  expect_equal(exp$fid$intensity, c(5, 6, 7))
  expect_equal(exp$ms$metadata, list(a = 1))
  expect_equal(exp$fid$metadata, list(b = 2))
  expect_equal(exp$alignment$delay, 0)
  expect_equal(exp$processing, list())
})

test_that("gcms_fid_exp() aborts on malformed MS data", {
  expect_error(
    gcms_fid_exp(matrix(1, 2, 2), c(1, 2), c(1, 1)),
    class = "moosaic-error-bad_format"
  )
})
