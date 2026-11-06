test_that(".sg_coefs() smoothing coefficients sum to 1 and match the known 5-point quadratic filter", {
  expect_equal(sum(.sg_coefs(5, 2)), 1)
  expect_equal(.sg_coefs(5, 2), c(-3, 12, 17, 12, -3) / 35)
})

test_that(".sg_coefs() first-derivative filter recovers the slope of a line", {
  x <- 3 * (1:20) + 1
  expect_equal(.apply_filter(x, .sg_coefs(7, 3, 1))[10], 3)
})

test_that(".sg_coefs() aborts on even windows and bad orders", {
  expect_error(.sg_coefs(6), class = "moosaic-error-bad_window")
  expect_error(.sg_coefs(5, order = 5), class = "moosaic-error-bad_argument")
  expect_error(
    .sg_coefs(5, order = 2, deriv = 3),
    class = "moosaic-error-bad_argument"
  )
})
