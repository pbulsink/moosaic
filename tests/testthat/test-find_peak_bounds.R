test_that(".find_peak_bounds() stops at the valley between two peaks", {
  x <- c(0, 1, 3, 5, 3, 1, 2, 4, 2, 0)
  expect_equal(.find_peak_bounds(x, 4L, floor = 0), c(start = 1L, end = 6L))
})

test_that(".find_peak_bounds() stops at the floor and at the ends", {
  x <- c(0.5, 1, 4, 1, 0.5)
  expect_equal(.find_peak_bounds(x, 3L, floor = 0.8), c(start = 1L, end = 5L))
  expect_equal(.find_peak_bounds(c(3, 2, 1), 1L), c(start = 1L, end = 3L))
})

test_that(".find_peak_bounds() ignores noise bumps smaller than tol", {
  x <- c(0, 2, 4, 3.8, 4.1, 5, 3, 1, 0)
  expect_equal(.find_peak_bounds(x, 4L, floor = 0), c(start = 4L, end = 4L))
  expect_equal(
    .find_peak_bounds(x, 6L, floor = 0, tol = 0.5),
    c(start = 1L, end = 9L)
  )
})
