gauss <- function(rt, c, w, h = 100) h * exp(-0.5 * ((rt - c) / w)^2)

trace <- \(rt, delay) {
  list(
    rt = rt,
    intensity = gauss(rt - delay, 3, 0.03) +
      gauss(rt - delay, 6, 0.03, 60) +
      gauss(rt - delay, 8, 0.05, 30)
  )
}

test_that(".estimate_delay_xcorr() recovers a known shift within one grid step", {
  fid <- trace(seq(0, 10, by = 0.0003), 0)
  tic <- trace(seq(0, 10, by = 0.0045), 0.05)
  out <- .estimate_delay_xcorr(fid, tic, max_delay = 0.2, step = 0.001)
  expect_equal(out$delay, 0.05, tolerance = 0.001 / 0.05)
  expect_gt(out$score, 0.95)
})

test_that(".estimate_delay_xcorr() recovers a negative shift", {
  fid <- trace(seq(0, 10, by = 0.0003), 0)
  tic <- trace(seq(0, 10, by = 0.0045), -0.03)
  out <- .estimate_delay_xcorr(fid, tic, max_delay = 0.2, step = 0.001)
  expect_equal(out$delay, -0.03, tolerance = 0.001 / 0.03)
})

test_that(".estimate_delay_xcorr() handles a flat trace without error", {
  fid <- list(rt = seq(0, 1, by = 0.01), intensity = rep(0, 101))
  tic <- list(rt = seq(0, 1, by = 0.01), intensity = rep(0, 101))
  out <- .estimate_delay_xcorr(fid, tic, max_delay = 0.05, step = 0.01)
  expect_equal(out$score, 0)
})
