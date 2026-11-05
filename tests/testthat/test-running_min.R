test_that(".running_min() matches a brute-force centred minimum", {
  x <- c(5, 3, 8, 1, 9, 4, 7, 2, 6)
  w <- 3
  xp <- c(x[1], x, x[length(x)])
  expected <- vapply(seq_along(x), \(i) min(xp[i:(i + 2)]), numeric(1))
  expect_equal(.running_min(x, w), expected)
})

test_that(".running_min() handles windows longer than a block boundary", {
  set.seed(5521)
  x <- rnorm(101)
  w <- 11
  xp <- c(rep(x[1], 5), x, rep(x[101], 5))
  expected <- vapply(seq_along(x), \(i) min(xp[i:(i + 10)]), numeric(1))
  expect_equal(.running_min(x, w), expected)
})
