test_that(".find_shoulders() finds both minima of a doublet second derivative", {
  d2 <- c(0, -1, -3, -1, 0.5, -2, -4, -2, 0)
  expect_equal(.find_shoulders(d2), c(3L, 7L))
})

test_that(".find_shoulders() excludes minima at known apexes", {
  d2 <- c(0, -1, -3, -1, 0.5, -2, -4, -2, 0)
  expect_equal(.find_shoulders(d2, apex_idx = 7L, tol = 1L), 3L)
})

test_that(".find_shoulders() applies the prominence threshold and handles short input", {
  d2 <- c(0, -1, -3, -1, 0.5, -2, -4, -2, 0)
  expect_equal(.find_shoulders(d2, min_prominence = 3.5), 7L)
  expect_equal(.find_shoulders(c(0, -1)), integer())
})

test_that(".find_shoulders() counts a prominent dip that stays positive", {
  # Apex dip at 3, then a dip from 8 down to 5 on the positive flank
  d2 <- c(0, -2, -5, -2, 4, 8, 6, 5, 7, 9, 3)
  expect_equal(.find_shoulders(d2, apex_idx = 3L, min_prominence = 2), 8L)
  expect_equal(
    .find_shoulders(d2, apex_idx = 3L, min_prominence = 4),
    integer()
  )
})
