test_that(".find_local_maxima() finds interior maxima", {
  expect_equal(.find_local_maxima(c(0, 1, 3, 1, 0, 2, 0)), c(3L, 6L))
})

test_that(".find_local_maxima() respects min_height", {
  expect_equal(.find_local_maxima(c(0, 1, 3, 1, 0, 2, 0), 2.5), 3L)
})

test_that(".find_local_maxima() reports the first point of a flat top and short input is empty", {
  expect_equal(.find_local_maxima(c(0, 2, 2, 0)), 2L)
  expect_equal(.find_local_maxima(c(1, 2)), integer())
})
