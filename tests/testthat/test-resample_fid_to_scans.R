test_that(".resample_fid_to_scans() averages all FID points in a scan interval", {
  # 14 points inside the interval (0.5, 1.5) of the scan at 1
  fid_rt <- 1 + (-7:6) / 14 * 0.9
  out <- .resample_fid_to_scans(fid_rt, 1:14, c(1, 2, 3))
  expect_equal(out[1], 7.5)
  expect_true(all(is.na(out[2:3])))
})

test_that(".resample_fid_to_scans() uses midpoints between scans as interval edges", {
  fid_rt <- c(0.6, 0.9, 1.2, 1.4, 1.6, 2.0, 2.4)
  out <- .resample_fid_to_scans(fid_rt, 1:7, c(1, 2))
  expect_equal(out, c(mean(1:4), mean(5:7)))
})

test_that(".resample_fid_to_scans() assigns a boundary point to the later scan", {
  out <- .resample_fid_to_scans(c(0.9, 1.5, 2.1), c(10, 20, 30), c(1, 2))
  expect_equal(out, c(10, 25))
})

test_that(".resample_fid_to_scans() ignores points outside the scan range", {
  out <- .resample_fid_to_scans(c(-5, 1, 2, 50), c(100, 1, 3, 100), c(1, 2))
  expect_equal(out, c(1, 3))
})

test_that(".resample_fid_to_scans() keeps a narrow spike instead of aliasing it away", {
  fid_rt <- seq(0.5, 1.5, length.out = 21)[-21]
  y <- rep(0, 20)
  y[7] <- 20
  expect_equal(.resample_fid_to_scans(fid_rt, y, c(1, 2))[1], 1)
})

test_that(".resample_fid_to_scans() aborts on bad input", {
  expect_error(
    .resample_fid_to_scans(1:3, 1:3, 1),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    .resample_fid_to_scans(1:3, 1:2, c(1, 2)),
    class = "moosaic-error-bad_argument"
  )
})
