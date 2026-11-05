spec <- \(mz) setNames(rep(1, length(mz)), mz)

test_that("detect_fid_windows() finds windows without modifying the raw FID", {
  exp <- make_synthetic_run(
    n_comp = 3,
    centers = c(5, 10, 10.05),
    widths = c(0.04, 0.04, 0.04),
    spectra = list(spec(c(40, 41)), spec(c(50, 51)), spec(c(60, 61))),
    carbons = c(1, 2, 3)
  )
  before <- exp$fid
  w <- detect_fid_windows(exp)
  expect_identical(exp$fid, before)
  expect_equal(nrow(w), 2L)
  expect_true(all(w$n_scans >= 8))
  expect_s3_class(attr(w, "peaks"), "tbl_df")
  expect_true(w$start_rt[2] < 10 && w$end_rt[2] > 10.05)
})

test_that("detect_fid_windows() warns about windows with few MS scans", {
  exp <- make_synthetic_run(
    n_comp = 1,
    centers = 5,
    widths = 0.04,
    spectra = list(spec(c(40, 41))),
    carbons = 1
  )
  withr::local_options(moosaic.min_scans_per_window = 10000L)
  expect_warning(detect_fid_windows(exp), class = "moosaic-warning-few_scans")
})

test_that("detect_fid_windows() rejects non-experiments", {
  expect_error(detect_fid_windows(list()), class = "moosaic-error-bad_argument")
})
