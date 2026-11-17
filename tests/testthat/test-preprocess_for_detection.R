test_that(".preprocess_for_detection() does not modify its input and returns noise", {
  set.seed(2216)
  rt <- seq(0, 2, length.out = 800)
  fid <- list(rt = rt, intensity = 5 + rt + rnorm(800, sd = 0.2))
  before <- fid
  out <- .preprocess_for_detection(fid)
  expect_identical(fid, before)
  expect_named(out, c("rt", "intensity", "noise"))
  expect_equal(out$noise, 0.2, tolerance = 0.2)
  expect_lt(abs(mean(out$intensity)), 0.5)
})

test_that(".preprocess_for_detection() uses smooth_window over the option", {
  set.seed(2217)
  x <- list(rt = 1:200, intensity = rnorm(200))
  withr::local_options(moosaic.fid_smooth_window = 7L)
  narrow <- .preprocess_for_detection(x)
  wide <- .preprocess_for_detection(x, smooth_window = 31L)
  expect_lt(sd(diff(wide$intensity)), sd(diff(narrow$intensity)))
})
