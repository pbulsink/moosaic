test_that(".apply_filter() with a moving average repeats edge values", {
  out <- .apply_filter(c(1, 2, 3, 4, 5), rep(1 / 3, 3))
  expect_equal(out, c(4 / 3, 2, 3, 4, 14 / 3))
})
