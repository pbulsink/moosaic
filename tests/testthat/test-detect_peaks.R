gauss <- function(rt, c, w, h = 100) h * exp(-0.5 * ((rt - c) / w)^2)

peak_cols <- c(
  "peak_id",
  "apex_rt",
  "start_rt",
  "end_rt",
  "height",
  "has_shoulder",
  "is_shoulder",
  "parent_id"
)

doublet <- function() {
  set.seed(8842)
  rt <- seq(0, 4, by = 1 / 3000)
  y <- gauss(rt, 2, 0.03) +
    gauss(rt, 2.06, 0.03, 60) +
    rnorm(length(rt), sd = 0.02)
  list(rt = rt, intensity = y)
}

test_that("detect_peaks() finds separated peaks with apex close to truth", {
  set.seed(8841)
  rt <- seq(0, 6, by = 1 / 3000)
  y <- gauss(rt, 1.5, 0.02) +
    gauss(rt, 3, 0.02, 50) +
    gauss(rt, 4.5, 0.02, 80) +
    rnorm(length(rt), sd = 0.2)
  pk <- detect_peaks(list(rt = rt, intensity = y))
  expect_equal(nrow(pk), 3L)
  # Noise on a flat Gaussian top shifts the apex by a few points
  expect_lt(max(abs(pk$apex_rt - c(1.5, 3, 4.5))), 10 / 3000)
  expect_false(any(pk$has_shoulder))
  expect_false(any(pk$is_shoulder))
  expect_true(all(is.na(pk$parent_id)))
  expect_true(all(pk$start_rt < pk$apex_rt & pk$apex_rt < pk$end_rt))
})

test_that("detect_peaks() returns a fused doublet as a parent and a shoulder row", {
  pk <- detect_peaks(doublet())
  expect_equal(nrow(pk), 2L)
  expect_equal(pk$peak_id, 1:2)
  expect_equal(pk$is_shoulder, c(FALSE, TRUE))
  expect_equal(pk$has_shoulder, c(TRUE, FALSE))
  expect_equal(pk$parent_id, c(NA_integer_, 1L))
  expect_lt(abs(pk$apex_rt[1] - 2), 0.01)
  expect_lt(abs(pk$apex_rt[2] - 2.06), 0.02)
})

test_that("detect_peaks() splits the parent span between apex and shoulder", {
  pk <- detect_peaks(doublet())
  whole <- detect_peaks(doublet(), include_shoulders = FALSE)
  expect_equal(pk$start_rt[1], whole$start_rt)
  expect_equal(pk$end_rt[2], whole$end_rt)
  expect_lt(pk$end_rt[1], pk$start_rt[2])
  expect_true(all(pk$start_rt <= pk$apex_rt & pk$apex_rt <= pk$end_rt))
})

test_that("detect_peaks() keeps has_shoulder but drops shoulder rows when asked", {
  pk <- detect_peaks(doublet(), include_shoulders = FALSE)
  expect_equal(nrow(pk), 1L)
  expect_true(pk$has_shoulder)
  expect_false(pk$is_shoulder)
  expect_error(
    detect_peaks(doublet(), include_shoulders = NA),
    class = "moosaic-error-bad_argument"
  )
})

test_that("detect_peaks() numbers parents correctly when shoulders precede peaks", {
  set.seed(8845)
  rt <- seq(0, 6, by = 1 / 3000)
  y <- gauss(rt, 2, 0.03) +
    gauss(rt, 2.06, 0.03, 60) +
    gauss(rt, 4, 0.03, 80) +
    rnorm(length(rt), sd = 0.02)
  pk <- detect_peaks(list(rt = rt, intensity = y))
  expect_equal(nrow(pk), 3L)
  expect_equal(pk$is_shoulder, c(FALSE, TRUE, FALSE))
  expect_equal(pk$parent_id, c(NA, 1L, NA))
})

# Minor component fused into a 100-high main peak (sigma 0.03 min, FID 50 Hz).
# At <= 3 sigma separation the sum has no local maximum at the minor apex.
minor_shoulder <- function(rel_height, sep_sigma, side = 1, sd = 0.2, seed) {
  set.seed(seed)
  rt <- seq(0, 4, by = 1 / 3000)
  y <- gauss(rt, 2, 0.03) +
    gauss(rt, 2 + side * sep_sigma * 0.03, 0.03, 100 * rel_height) +
    rnorm(length(rt), sd = sd)
  list(rt = rt, intensity = y)
}

shoulder_found <- function(pk, target, tol = 0.02) {
  any(pk$is_shoulder & abs(pk$apex_rt - target) < tol)
}

for (rel in c(0.05, 0.10)) {
  for (sep in c(2, 3)) {
    test_that(
      sprintf(
        "detect_peaks() finds a trailing %d%% shoulder at %g sigma with noise",
        round(100 * rel),
        sep
      ),
      {
        seeds <- 7101:7110
        found <- vapply(
          seeds,
          \(s) {
            pk <- detect_peaks(minor_shoulder(rel, sep, seed = s))
            shoulder_found(pk, 2 + sep * 0.03) &&
              sum(!pk$is_shoulder) == 1L &&
              all(pk$parent_id[pk$is_shoulder] == pk$peak_id[!pk$is_shoulder])
          },
          logical(1)
        )
        expect_gte(sum(found), 9L)
      }
    )
  }
}

test_that("detect_peaks() finds a leading 10% shoulder at 3 sigma with noise", {
  found <- vapply(
    7201:7210,
    \(s) {
      pk <- detect_peaks(minor_shoulder(0.10, 3, side = -1, seed = s))
      shoulder_found(pk, 2 - 3 * 0.03)
    },
    logical(1)
  )
  expect_gte(sum(found), 9L)
})

test_that("detect_peaks() finds a 10% shoulder at 3 sigma under heavier noise", {
  found <- vapply(
    7301:7310,
    \(s) {
      pk <- detect_peaks(minor_shoulder(0.10, 3, sd = 0.5, seed = s))
      shoulder_found(pk, 2 + 3 * 0.03)
    },
    logical(1)
  )
  expect_gte(sum(found), 8L)
})

test_that("detect_peaks() reports no shoulders on a lone noisy Gaussian", {
  n_sh <- vapply(
    7401:7420,
    \(s) {
      sum(detect_peaks(minor_shoulder(0, 0, sd = 0.5, seed = s))$is_shoulder)
    },
    integer(1)
  )
  expect_equal(sum(n_sh), 0L)
})

test_that("detect_peaks() returns a typed zero-row tibble without peaks", {
  set.seed(8843)
  rt <- seq(0, 2, length.out = 1000)
  pk <- detect_peaks(list(rt = rt, intensity = rnorm(1000, sd = 0.1)))
  expect_s3_class(pk, "tbl_df")
  expect_equal(nrow(pk), 0L)
  expect_named(pk, peak_cols)
  expect_type(pk$parent_id, "integer")
})

test_that("detect_peaks() returns the documented columns", {
  expect_named(detect_peaks(doublet()), peak_cols)
})

test_that("detect_peaks() respects min_snr and validates it", {
  set.seed(8844)
  rt <- seq(0, 2, by = 1 / 3000)
  y <- gauss(rt, 1, 0.02, 3) + rnorm(length(rt), sd = 0.2)
  trace <- list(rt = rt, intensity = y)
  expect_equal(nrow(detect_peaks(trace, min_snr = 5)), 1L)
  expect_equal(nrow(detect_peaks(trace, min_snr = 100)), 0L)
  expect_error(
    detect_peaks(trace, min_snr = -1),
    class = "moosaic-error-bad_argument"
  )
})

test_that("detect_peaks() passes smooth_window to the detection copy", {
  rt <- seq(0, 2, by = 1 / 3000)
  trace <- list(rt = rt, intensity = gauss(rt, 1, 0.02))
  expect_equal(nrow(detect_peaks(trace, smooth_window = 21L)), 1L)
  expect_error(
    detect_peaks(trace, smooth_window = 4L),
    class = "moosaic-error-bad_window"
  )
})

test_that("detect_peaks() handles noise-free input", {
  rt <- seq(0, 2, by = 1 / 3000)
  pk <- detect_peaks(list(rt = rt, intensity = gauss(rt, 1, 0.02)))
  expect_equal(nrow(pk), 1L)
})

test_that("detect_peaks() places the apex within one point on noise-free data", {
  rt <- seq(0, 2, by = 1 / 3000)
  pk <- detect_peaks(list(rt = rt, intensity = gauss(rt, 1, 0.02)))
  expect_lt(abs(pk$apex_rt - 1), 1 / 3000 + 1e-9)
})
