test_that(".rank_fid() counts the peaks in a clean FID window", {
  for (k in 1:3) {
    expect_equal(.rank_fid(make_lowrank(k)$fid), k)
  }
})

test_that(".rank_fid() returns zero for noise, a flat trace and a monotone ramp", {
  set.seed(5530)
  rt <- seq_len(40) * 0.0045
  expect_equal(.rank_fid(list(rt = rt, intensity = rnorm(40))), 0L)
  expect_equal(.rank_fid(list(rt = rt, intensity = rep(3, 40))), 0L)
  expect_equal(
    .rank_fid(list(rt = rt, intensity = seq(0, 100, length.out = 40))),
    0L
  )
})

test_that(".rank_fid() does not count a noise bump on a peak flank as a second peak", {
  fid <- make_lowrank(1)$fid
  fid$intensity[15] <- fid$intensity[15] * 1.01
  expect_equal(.rank_fid(fid), 1L)
})

test_that(".rank_fid() fills missing values by interpolation", {
  fid <- make_lowrank(2)$fid
  fid$intensity[c(3, 25)] <- NA
  expect_equal(.rank_fid(fid), 2L)
})

test_that(".rank_fid() returns NA when there are too few usable points", {
  expect_true(is.na(.rank_fid(list(rt = 1:4, intensity = c(1, 5, 1, 0)))))
  expect_true(is.na(.rank_fid(list(
    rt = 1:6,
    intensity = c(1, NA, NA, NA, NA, 2)
  ))))
})

test_that(".rank_fid() aborts on a malformed fid", {
  expect_error(.rank_fid(1:10), class = "moosaic-error-bad_argument")
  expect_error(
    .rank_fid(list(rt = 1:3, intensity = 1:4)),
    class = "moosaic-error-bad_argument"
  )
})
