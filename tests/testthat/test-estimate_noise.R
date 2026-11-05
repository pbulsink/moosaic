test_that(".estimate_noise() recovers the SD of white noise", {
  set.seed(7310)
  expect_equal(.estimate_noise(rnorm(20000, sd = 2)), 2, tolerance = 0.05)
})

test_that(".estimate_noise() ignores a large peak", {
  set.seed(7311)
  x <- rnorm(5000, sd = 1) + 1000 * exp(-0.5 * ((1:5000 - 2500) / 1500)^2)
  expect_equal(.estimate_noise(x), 1, tolerance = 0.1)
})
