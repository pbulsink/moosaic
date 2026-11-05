test_that(".preprocess_fid_for_detection() does not modify its input and returns noise", {
  set.seed(2216)
  rt <- seq(0, 2, length.out = 800)
  fid <- list(rt = rt, intensity = 5 + rt + rnorm(800, sd = 0.2))
  before <- fid
  out <- .preprocess_fid_for_detection(fid)
  expect_identical(fid, before)
  expect_named(out, c("rt", "intensity", "noise"))
  expect_equal(out$noise, 0.2, tolerance = 0.2)
  expect_lt(abs(mean(out$intensity)), 0.5)
})
