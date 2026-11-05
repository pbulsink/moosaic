test_that(".normalize_columns() scales each column to a maximum of 1", {
  M <- cbind(a = c(1, 2, 4), b = c(0, 5, 10))
  out <- .normalize_columns(M)
  expect_equal(apply(out, 2, max), c(a = 1, b = 1))
  expect_equal(out[, "a"], c(0.25, 0.5, 1))
  expect_equal(colnames(out), c("a", "b"))
})

test_that(".normalize_columns() leaves zero columns at zero", {
  out <- .normalize_columns(cbind(c(0, 0, 0), c(1, 2, 3)))
  expect_equal(out[, 1], c(0, 0, 0))
  expect_false(anyNA(out))
})
