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

test_that("detect_fid_windows() flags windows containing a shoulder peak", {
  exp <- make_synthetic_run(
    n_comp = 2,
    centers = c(5, 10),
    widths = c(0.04, 0.04),
    spectra = list(spec(c(40, 41)), spec(c(50, 51))),
    carbons = c(1, 2)
  )
  local_mocked_bindings(
    detect_peaks = \(...) {
      tibble::tibble(
        peak_id = 1:3,
        apex_rt = c(5, 10, 10.05),
        start_rt = c(4.9, 9.9, 10.0),
        end_rt = c(5.1, 10.04, 10.15),
        height = 1,
        has_shoulder = c(FALSE, FALSE, TRUE),
        is_shoulder = FALSE,
        parent_id = NA_integer_
      )
    }
  )
  w <- detect_fid_windows(exp)
  expect_equal(w$has_shoulder, c(FALSE, TRUE))
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

test_that("detect_fid_windows() few-scans warning handles several windows", {
  exp <- make_synthetic_run(
    n_comp = 2,
    centers = c(5, 10),
    widths = c(0.04, 0.04),
    spectra = list(spec(c(40, 41)), spec(c(50, 51))),
    carbons = c(1, 2)
  )
  withr::local_options(moosaic.min_scans_per_window = 10000L)
  expect_warning(detect_fid_windows(exp), "Window ids")
})

test_that("detect_fid_windows() retains enough scan context for very narrow cores", {
  exp <- make_synthetic_run(
    1,
    0.3,
    0.04,
    list(spec(c(40, 41))),
    1,
    duration = 0.6
  )
  apex <- exp$ms$rt[50]
  local_mocked_bindings(detect_peaks = \(...) {
    tibble::tibble(
      peak_id = 1L,
      apex_rt = apex,
      start_rt = apex - 0.0001,
      end_rt = apex + 0.0001,
      has_shoulder = FALSE
    )
  })
  withr::local_options(moosaic.window_padding = 0)
  w <- suppressWarnings(detect_fid_windows(exp))
  expect_gte(w$n_scans, 2L)
  expect_equal(w$core_start_rt, apex - 0.0001)
  expect_equal(w$core_end_rt, apex + 0.0001)
})

test_that("detect_fid_windows() localizes crowded peaks with aligned scan counts", {
  exp <- make_synthetic_run(
    1,
    0.3,
    0.04,
    list(spec(c(40, 41))),
    1,
    delay = 0.05,
    duration = 0.8
  )
  peaks <- tibble::tibble(
    peak_id = 1:6,
    apex_rt = seq(0.2, 0.7, 0.1),
    start_rt = apex_rt - 0.06,
    end_rt = apex_rt + 0.06,
    has_shoulder = c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE)
  )
  local_mocked_bindings(detect_peaks = \(...) peaks)
  withr::local_options(moosaic.window_max_peaks = 2L)
  w <- detect_fid_windows(exp)
  expect_equal(w$n_peaks, rep(2L, 3))
  expect_equal(w$has_shoulder, c(FALSE, TRUE, FALSE))
  expect_equal(
    w$n_scans,
    vapply(
      seq_len(nrow(w)),
      function(i) {
        sum(exp$ms$rt - 0.05 >= w$start_rt[i] & exp$ms$rt - 0.05 <= w$end_rt[i])
      },
      integer(1)
    )
  )
})
