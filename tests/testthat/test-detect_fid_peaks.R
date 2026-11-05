gauss <- function(rt, c, w, h = 100) h * exp(-0.5 * ((rt - c) / w)^2)

test_that("detect_fid_peaks() finds separated peaks with apex close to truth", {
  set.seed(8841)
  rt <- seq(0, 6, by = 1 / 3000)
  y <- gauss(rt, 1.5, 0.02) +
    gauss(rt, 3, 0.02, 50) +
    gauss(rt, 4.5, 0.02, 80) +
    rnorm(length(rt), sd = 0.2)
  pk <- detect_fid_peaks(list(rt = rt, intensity = y))
  expect_equal(nrow(pk), 3L)
  # Noise on a flat Gaussian top shifts the apex by a few points
  expect_lt(max(abs(pk$apex_rt - c(1.5, 3, 4.5))), 10 / 3000)
  expect_false(any(pk$shoulder))
  expect_true(all(pk$start_rt < pk$apex_rt & pk$apex_rt < pk$end_rt))
})

test_that("detect_fid_peaks() flags a fused doublet as shoulder", {
  set.seed(8842)
  rt <- seq(0, 4, by = 1 / 3000)
  y <- gauss(rt, 2, 0.03) +
    gauss(rt, 2.06, 0.03, 60) +
    rnorm(length(rt), sd = 0.02)
  pk <- detect_fid_peaks(list(rt = rt, intensity = y))
  expect_equal(nrow(pk), 1L)
  expect_true(pk$shoulder)
})

test_that("detect_fid_peaks() returns a typed zero-row tibble without peaks", {
  set.seed(8843)
  rt <- seq(0, 2, length.out = 1000)
  pk <- detect_fid_peaks(list(rt = rt, intensity = rnorm(1000, sd = 0.1)))
  expect_s3_class(pk, "tbl_df")
  expect_equal(nrow(pk), 0L)
  expect_named(
    pk,
    c("peak_id", "apex_rt", "start_rt", "end_rt", "height", "shoulder")
  )
})

test_that("detect_fid_peaks() respects min_snr and validates it", {
  set.seed(8844)
  rt <- seq(0, 2, by = 1 / 3000)
  y <- gauss(rt, 1, 0.02, 3) + rnorm(length(rt), sd = 0.2)
  fid <- list(rt = rt, intensity = y)
  expect_equal(nrow(detect_fid_peaks(fid, min_snr = 5)), 1L)
  expect_equal(nrow(detect_fid_peaks(fid, min_snr = 100)), 0L)
  expect_error(
    detect_fid_peaks(fid, min_snr = -1),
    class = "moosaic-error-bad_argument"
  )
})

test_that("detect_fid_peaks() handles noise-free input", {
  rt <- seq(0, 2, by = 1 / 3000)
  pk <- detect_fid_peaks(list(rt = rt, intensity = gauss(rt, 1, 0.02)))
  expect_equal(nrow(pk), 1L)
})

test_that("detect_fid_peaks() places the apex within one point on noise-free data", {
  rt <- seq(0, 2, by = 1 / 3000)
  pk <- detect_fid_peaks(list(rt = rt, intensity = gauss(rt, 1, 0.02)))
  expect_lt(abs(pk$apex_rt - 1), 1 / 3000 + 1e-9)
})
