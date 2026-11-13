test_that(".rank_pfr() returns the exact rank of noiseless data", {
  for (k in 1:3) {
    expect_equal(.rank_pfr(make_lowrank(k)$D, 0.95, 6), k)
  }
})

test_that(".rank_pfr() recovers rank 1 to 3 from noisy data", {
  for (k in 1:3) {
    D <- make_lowrank(k, noise = 5, seed = 5120 + k)$D
    expect_equal(.rank_pfr(D, 0.95, 6), k)
  }
})

test_that(".rank_pfr() finds a minor co-eluting component", {
  set.seed(5131)
  x <- make_lowrank(2)
  C <- x$C
  C[, 2] <- 0.2 * exp(-0.5 * ((seq_len(40) - 16) / 3)^2)
  D <- 100 * C %*% t(x$S) + matrix(rnorm(1200, sd = 5), 40)
  expect_equal(.rank_pfr(D, 0.95, 6), 2L)
})

test_that(".rank_pfr() returns zero for pure noise and an all-zero matrix", {
  set.seed(5140)
  expect_equal(.rank_pfr(matrix(rnorm(1200), 40), 0.95, 6), 0L)
  expect_equal(.rank_pfr(matrix(0, 10, 5), 0.95, 6), 0L)
})

test_that(".rank_pfr() caps the rank at max_rank", {
  expect_equal(.rank_pfr(make_lowrank(3)$D, 0.95, 2), 2L)
})

test_that(".rank_pfr() returns NA when the window is too small to test", {
  expect_true(is.na(.rank_pfr(matrix(1:6, 2), 0.95, 6)))
  expect_true(is.na(.rank_pfr(matrix(1:10, 10), 0.95, 6)))
})

test_that(".rank_pfr() aborts on an invalid cutoff", {
  D <- make_lowrank(1)$D
  expect_error(.rank_pfr(D, 0, 6), class = "moosaic-error-bad_argument")
  expect_error(.rank_pfr(D, 1, 6), class = "moosaic-error-bad_argument")
  expect_error(
    .rank_pfr(D, c(0.9, 0.95), 6),
    class = "moosaic-error-bad_argument"
  )
})
