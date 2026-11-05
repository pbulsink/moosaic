test_that(".peak_prominence() measures height above the higher of the two bases", {
  x <- c(0, 1, 3, 1, 0, 2, 0)
  expect_equal(.peak_prominence(x, c(3L, 6L)), c(3, 2))
})

test_that(".peak_prominence() gives a small value to a bump on a flank", {
  x <- c(0, 5, 4, 4.5, 0)
  expect_equal(.peak_prominence(x, 4L), 0.5)
})

test_that(".peak_prominence() returns an empty vector for no indices", {
  expect_equal(.peak_prominence(c(0, 1, 0), integer()), numeric())
})
