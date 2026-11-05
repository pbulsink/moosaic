test_that(".rank_pa() returns the exact rank of noiseless data", {
  set.seed(2290)
  for (k in 1:3) {
    expect_equal(.rank_pa(make_lowrank(k)$D, 50, 6), k)
  }
})

test_that(".rank_pa() recovers the rank at low noise", {
  set.seed(2291)
  expect_equal(.rank_pa(make_lowrank(3, noise = 0.5)$D, 50, 6), 3L)
})

test_that(".rank_pa() is capped at max_rank", {
  set.seed(2292)
  expect_equal(.rank_pa(make_lowrank(3)$D, 50, 2), 2L)
})

test_that(".rank_pa() returns zero for pure noise and for an all-zero matrix", {
  set.seed(2293)
  expect_equal(.rank_pa(matrix(rnorm(1200), 40), 50, 6), 0L)
  expect_equal(.rank_pa(matrix(0, 5, 4), 10, 3), 0L)
})

test_that(".rank_pa() handles a matrix with a single column and validates iterations", {
  set.seed(2294)
  expect_lte(.rank_pa(matrix(c(1, 3, 2, 5), ncol = 1), 20, 3), 1L)
  expect_error(
    .rank_pa(matrix(1:4, 2), 0, 1),
    class = "moosaic-error-bad_argument"
  )
})
