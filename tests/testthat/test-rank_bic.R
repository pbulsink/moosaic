test_that(".rank_bic() returns the exact rank of noiseless data", {
  for (k in 1:3) {
    expect_equal(.rank_bic(make_lowrank(k)$D, 6), k)
  }
})

test_that(".rank_bic() recovers the rank at low noise", {
  expect_equal(.rank_bic(make_lowrank(3, noise = 0.5, seed = 4417)$D, 6), 3L)
})

test_that(".rank_bic() is capped at max_rank and at the smallest dimension", {
  D <- make_lowrank(3)$D
  expect_equal(.rank_bic(D, 2), 2L)
  expect_lte(.rank_bic(make_lowrank(2, n_scan = 5, n_mz = 4)$D, 10), 4L)
})

test_that(".rank_bic() returns zero for pure noise and for an all-zero matrix", {
  set.seed(6172)
  expect_equal(.rank_bic(matrix(rnorm(1200), 40), 6), 0L)
  expect_equal(.rank_bic(matrix(0, 5, 4), 3), 0L)
})
