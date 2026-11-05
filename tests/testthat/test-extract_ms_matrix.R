spec <- \(mz) setNames(rep(1, length(mz)), mz)

mk_exp <- \(delay = 0) {
  make_synthetic_run(
    n_comp = 2,
    centers = c(5, 10),
    widths = c(0.04, 0.04),
    spectra = list(spec(c(40, 41)), spec(c(50, 51))),
    carbons = 1:2,
    delay = delay
  )
}

w10 <- list(window_id = 2L, start_rt = 9.8, end_rt = 10.2)

test_that("extract_ms_matrix() returns D, rt, mz and window_id for the window", {
  exp <- mk_exp()
  out <- extract_ms_matrix(exp, w10)
  expect_named(out, c("D", "rt", "mz", "window_id"))
  expect_equal(out$window_id, 2L)
  expect_equal(nrow(out$D), length(out$rt))
  expect_equal(ncol(out$D), length(out$mz))
  expect_true(all(out$rt >= 9.8 & out$rt <= 10.2))
})

test_that("extract_ms_matrix() drops m/z channels with no signal in the window", {
  out <- extract_ms_matrix(mk_exp(), w10)
  expect_equal(out$mz, c(50, 51))
  expect_equal(colnames(out$D), c("50", "51"))
})

test_that("extract_ms_matrix() reports times on the FID axis after alignment", {
  exp <- mk_exp(0.05)
  exp$alignment$delay <- 0.05
  out <- extract_ms_matrix(exp, w10)
  expect_true(all(out$rt >= 9.8 & out$rt <= 10.2))
  apex <- out$rt[which.max(rowSums(out$D))]
  expect_lt(abs(apex - 10), stats::median(diff(out$rt)))
  # raw MS times are untouched
  expect_equal(exp$ms$rt, mk_exp(0.05)$ms$rt)
})

test_that("extract_ms_matrix() uses the unaligned axis when no delay is recorded", {
  exp <- mk_exp()
  exp$alignment$delay <- NULL
  expect_gt(nrow(extract_ms_matrix(exp, w10)$D), 0L)
})

test_that("extract_ms_matrix() accepts a row of detect_fid_windows()", {
  exp <- mk_exp()
  w <- detect_fid_windows(exp)
  out <- extract_ms_matrix(exp, w[2, ])
  expect_equal(out$window_id, 2L)
})

test_that("extract_ms_matrix() aborts for a window outside the run and for non-experiments", {
  expect_error(
    extract_ms_matrix(mk_exp(), list(start_rt = 500, end_rt = 501)),
    class = "moosaic-error-empty_window"
  )
  expect_error(
    extract_ms_matrix(list(), w10),
    class = "moosaic-error-bad_argument"
  )
})

test_that("resampled FID apex lines up with the MS apex after alignment", {
  exp <- align_detectors(mk_exp(0.05), engine = "xcorr")
  ms <- extract_ms_matrix(exp, w10)
  fw <- .extract_fid_window(exp, w10)
  apex_ms <- ms$rt[which.max(rowSums(ms$D))]
  apex_fid <- fw$rt[which.max(fw$intensity)]
  expect_lt(abs(apex_ms - apex_fid), stats::median(diff(ms$rt)) * 1.01)
})
