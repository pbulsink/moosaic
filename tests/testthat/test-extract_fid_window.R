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

test_that(".extract_fid_window() returns one FID value per MS scan in the window", {
  exp <- mk_exp()
  fw <- .extract_fid_window(exp, w10)
  ms <- extract_ms_matrix(exp, w10)
  expect_named(fw, c("rt", "intensity"))
  expect_equal(fw$rt, ms$rt)
  expect_length(fw$intensity, nrow(ms$D))
  expect_false(anyNA(fw$intensity))
})

test_that(".extract_fid_window() returns raw intensities when raw = TRUE and a baseline-corrected copy otherwise", {
  exp <- mk_exp()
  edge <- list(window_id = 1L, start_rt = 9.0, end_rt = 9.2)
  raw <- .extract_fid_window(exp, edge, raw = TRUE)
  det <- .extract_fid_window(exp, edge, raw = FALSE)
  # synthetic baseline is 5 + 0.02 * rt, away from any peak
  expect_gt(min(raw$intensity), 5)
  expect_lt(max(abs(det$intensity)), 1)
})

test_that(".extract_fid_window() does not modify the experiment", {
  exp <- mk_exp()
  before <- exp
  .extract_fid_window(exp, w10)
  .extract_fid_window(exp, w10, raw = TRUE)
  expect_identical(exp, before)
})

test_that(".extract_fid_window() aborts for a window outside the run", {
  expect_error(
    .extract_fid_window(mk_exp(), list(start_rt = 500, end_rt = 501)),
    class = "moosaic-error-empty_window"
  )
})
