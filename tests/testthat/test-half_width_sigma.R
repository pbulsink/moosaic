test_that(".half_width_sigma() recovers the sigma of a Gaussian", {
  x <- 1:2001
  y <- exp(-0.5 * ((x - 1000) / 50)^2)
  expect_equal(.half_width_sigma(y, 1000L, 1L, 2001L), 50, tolerance = 0.02)
})

test_that(".half_width_sigma() falls back to the bounds without a half crossing", {
  y <- c(1, 2, 3, 2, 1.8)
  # Left crosses half height 2 points out; right never does, so uses the bound
  expect_equal(.half_width_sigma(y, 3L, 1L, 5L), (2 + 2) / 2.355)
  expect_equal(.half_width_sigma(c(1, 1, 1), 2L, 2L, 2L), 1)
})
