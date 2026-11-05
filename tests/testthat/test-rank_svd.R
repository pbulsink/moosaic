test_that(".rank_svd() returns the exact rank of noiseless data", {
  for (k in 1:3) {
    expect_equal(.rank_svd(make_lowrank(k)$D, 0.99), k)
  }
})

test_that(".rank_svd() returns fewer components for a lower variance threshold", {
  D <- make_lowrank(3)$D
  expect_lte(.rank_svd(D, 0.5), 2L)
  expect_equal(.rank_svd(D, 1), 3L)
})

test_that(".rank_svd() returns zero for an all-zero matrix", {
  expect_equal(.rank_svd(matrix(0, 5, 4), 0.99), 0L)
})

test_that(".rank_svd() aborts on an invalid threshold", {
  D <- make_lowrank(1)$D
  expect_error(.rank_svd(D, 0), class = "moosaic-error-bad_argument")
  expect_error(.rank_svd(D, 1.5), class = "moosaic-error-bad_argument")
  expect_error(.rank_svd(D, c(0.9, 0.99)), class = "moosaic-error-bad_argument")
})
