test_that(".leading_singular_values() matches svd() for wide and tall matrices", {
  set.seed(9902)
  for (dims in list(c(20, 60), c(60, 20))) {
    X <- matrix(rnorm(prod(dims)), dims[1])
    expect_equal(.leading_singular_values(X, 5), svd(X, 0, 0)$d[1:5])
  }
})

test_that(".leading_singular_values() caps k at the smallest dimension", {
  expect_length(.leading_singular_values(matrix(1:6, 2), 10), 2L)
})

test_that(".leading_singular_values() returns zeros for an all-zero matrix", {
  expect_equal(.leading_singular_values(matrix(0, 3, 4), 2), c(0, 0))
})
