test_that(".build_s0() returns non-negative columns with maximum 1", {
  set.seed(4817)
  D <- abs(matrix(rnorm(60), 10, 6))
  S0 <- .build_s0(D, 3)
  expect_equal(dim(S0), c(6L, 3L))
  expect_true(all(S0 >= 0))
  expect_equal(unname(apply(S0, 2, max)), rep(1, 3))
})

test_that(".build_s0() keeps all-zero columns finite", {
  D <- cbind(1:4, 0, c(2, 1, 2, 1))
  expect_false(anyNA(.build_s0(D, 2)))
})

test_that(".build_s0() aborts when rank is too large or invalid", {
  D <- matrix(1, 3, 5)
  expect_error(.build_s0(D, 4), class = "moosaic-error-bad_rank")
  expect_error(.build_s0(D, 0), class = "moosaic-error-bad_argument")
})
