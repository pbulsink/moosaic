test_that(".standardize_fid() converts a matrix to internal list structure", {
  fid_mat <- matrix(c(0.001, 0.002, 0.003, 100, 200, 150), nrow = 3, ncol = 2)
  attr(fid_mat, "sample_name") <- "test"

  fid <- .standardize_fid(fid_mat)
  expect_type(fid, "list")
  expect_named(fid, c("rt", "intensity"))
  expect_length(fid$rt, 3)
  expect_length(fid$intensity, 3)
})


test_that(".standardize_fid() converts a data.frame", {
  fid_df <- data.frame(rt = c(0.001, 0.002), intensity = c(100, 200))
  fid <- .standardize_fid(fid_df)
  expect_type(fid, "list")
  expect_equal(fid$rt, c(0.001, 0.002))
})


test_that(".standardize_fid() aborts on wrong column count", {
  bad_mat <- matrix(1:6, nrow = 2, ncol = 3)
  expect_error(
    .standardize_fid(bad_mat),
    class = "moosaic-error-bad_format"
  )
})
