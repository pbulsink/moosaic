test_that(".drop_empty_mz() removes all-zero columns and keeps labels", {
  D <- cbind("40" = c(1, 0, 2), "41" = c(0, 0, 0), "42" = c(0, 3, 0))
  out <- .drop_empty_mz(D)
  expect_equal(colnames(out), c("40", "42"))
  expect_equal(out[, "42"], c(0, 3, 0))
  expect_equal(nrow(out), 3L)
})

test_that(".drop_empty_mz() leaves a matrix with no empty columns unchanged", {
  D <- cbind("40" = c(1, 2), "41" = c(3, 4))
  expect_identical(.drop_empty_mz(D), D)
})

test_that(".drop_empty_mz() returns a zero-column matrix when everything is empty", {
  out <- .drop_empty_mz(matrix(
    0,
    2,
    3,
    dimnames = list(NULL, c("1", "2", "3"))
  ))
  expect_equal(dim(out), c(2L, 0L))
})
