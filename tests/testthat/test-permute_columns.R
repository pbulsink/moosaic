test_that(".permute_columns() keeps every column's values but shuffles their order", {
  set.seed(3380)
  X <- matrix(rnorm(300), 30)
  P <- .permute_columns(X)
  expect_equal(dim(P), dim(X))
  expect_equal(apply(P, 2, sort), apply(X, 2, sort))
  expect_false(identical(P, X))
})

test_that(".permute_columns() permutes columns independently", {
  set.seed(3381)
  X <- matrix(rep(1:30, 2), 30)
  P <- .permute_columns(X)
  expect_false(identical(P[, 1], P[, 2]))
})
