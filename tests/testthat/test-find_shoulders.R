test_that(".find_shoulders() finds both minima of a doublet second derivative", {
  d2 <- c(0, -1, -3, -1, 0.5, -2, -4, -2, 0)
  expect_equal(.find_shoulders(d2), c(3L, 7L))
})

test_that(".find_shoulders() excludes minima at known apexes", {
  d2 <- c(0, -1, -3, -1, 0.5, -2, -4, -2, 0)
  expect_equal(.find_shoulders(d2, apex_idx = 7L, tol = 1L), 3L)
})

test_that(".find_shoulders() applies the depth threshold and handles short input", {
  d2 <- c(0, -1, -3, -1, 0.5, -2, -4, -2, 0)
  expect_equal(.find_shoulders(d2, min_depth = 3.5), 7L)
  expect_equal(.find_shoulders(c(0, -1)), integer())
})
