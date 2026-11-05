
test_that(".standardize_ms() handles long-format matrix", {
  ms_mat <- matrix(
    c(0.001, 0.001, 0.002, 0.002, 39.9, 40.1, 39.9, 40.1, 100, 200, 150, 250),
    ncol = 3,
    byrow = FALSE
  )
  colnames(ms_mat) <- c("rt", "mz", "intensity")

  ms <- .standardize_ms(ms_mat)
  expect_type(ms, "list")
  expect_named(ms, c("data", "rt", "tic"))
  expect_length(ms$rt, 2)
  expect_equal(ms$tic[1], 300) # 100 + 200
})


test_that(".standardize_ms() computes TIC correctly", {
  ms_mat <- matrix(
    c(0.001, 0.001, 0.002, 40, 40, 40, 100, 50, 75),
    ncol = 3,
    byrow = FALSE
  )
  colnames(ms_mat) <- c("rt", "mz", "intensity")

  ms <- .standardize_ms(ms_mat)
  expect_equal(ms$tic, c(150, 75))
})


test_that(".standardize_ms() aborts on missing columns", {
  bad_mat <- matrix(1:6, nrow = 3, ncol = 2)
  colnames(bad_mat) <- c("a", "b")
  expect_error(
    .standardize_ms(bad_mat),
    class = "moosaic-error-bad_format"
  )
})

