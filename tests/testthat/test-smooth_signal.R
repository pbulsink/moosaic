test_that(".smooth_signal() preserves peak area within 1%", {
  x <- seq(-5, 5, length.out = 501)
  y <- exp(-0.5 * x^2)
  expect_equal(sum(.smooth_signal(y, 7)), sum(y), tolerance = 0.01)
})

test_that(".smooth_signal() leaves a polynomial of the filter order unchanged", {
  x <- seq(0, 1, length.out = 50)
  y <- 2 + x - 3 * x^2
  expect_equal(.smooth_signal(y, 7, 2)[5:45], y[5:45])
})

test_that(".smooth_signal() aborts on even windows and short input", {
  expect_error(.smooth_signal(1:20, 6), class = "moosaic-error-bad_window")
  expect_error(.smooth_signal(1:3, 7), class = "moosaic-error-bad_window")
})
