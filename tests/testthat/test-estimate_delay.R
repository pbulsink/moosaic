gauss <- function(rt, c, w, h = 100) h * exp(-0.5 * ((rt - c) / w)^2)

mk_trace <- \(rt, delay) {
  list(
    rt = rt,
    intensity = gauss(rt - delay, 3, 0.03) +
      gauss(rt - delay, 6, 0.03, 60) +
      gauss(rt - delay, 8, 0.05, 30)
  )
}

test_that(".estimate_delay() dispatches to each engine and labels the result", {
  fid <- mk_trace(seq(0, 10, by = 0.0003), 0)
  tic <- mk_trace(seq(0, 10, by = 0.0045), 0.05)
  x <- .estimate_delay(fid, tic, "xcorr", 0.2, 0.001)
  expect_equal(x$engine, "xcorr")
  expect_equal(x$delay, 0.05, tolerance = 0.03)
  g <- .estimate_delay(fid, tic, "gcalignr", 0.2, 0.005)
  expect_equal(g$engine, "gcalignr")
  expect_true(is.na(g$score))
  expect_equal(g$delay, 0.05, tolerance = 0.1)
})

test_that(".estimate_delay() aborts on an unknown engine", {
  expect_error(
    .estimate_delay(list(), list(), "magic", 0.2, 0.001),
    class = "moosaic-error-unknown_engine"
  )
  expect_error(
    .estimate_delay(list(), list(), 1, 0.2, 0.001),
    class = "moosaic-error-unknown_engine"
  )
})

test_that(".estimate_delay() warns when the delay sits at the search limit", {
  fid <- mk_trace(seq(0, 10, by = 0.0003), 0)
  tic <- mk_trace(seq(0, 10, by = 0.0045), 0.05)
  expect_warning(
    .estimate_delay(fid, tic, "xcorr", max_delay = 0.05, step = 0.001),
    class = "moosaic-warning-delay_at_limit"
  )
})
