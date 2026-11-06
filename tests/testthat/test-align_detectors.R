spec <- function(mz) {
  setNames(rep(1, length(mz)), mz)
}

mk_exp <- function(delay) {
  make_synthetic_run(
    n_comp = 4,
    centers = c(5, 10, 15, 20),
    widths = rep(0.04, 4),
    spectra = list(
      spec(c(40, 41)),
      spec(c(50, 51)),
      spec(c(60, 61)),
      spec(c(70, 71))
    ),
    carbons = 1:4,
    delay = delay
  )
}

test_that("align_detectors() recovers synthetic delays of 0 and 0.05 with both engines", {
  for (delay in c(0, 0.05)) {
    exp <- mk_exp(delay)
    scan <- stats::median(diff(exp$ms$rt))
    for (eng in c("xcorr", "gcalignr")) {
      out <- align_detectors(exp, engine = eng)
      expect_lt(abs(out$alignment$delay - delay), scan)
      expect_equal(out$alignment$engine, eng)
    }
  }
})

test_that("align_detectors() records the cross-check and leaves raw data unchanged", {
  exp <- mk_exp(0.05)
  out <- align_detectors(exp, engine = "xcorr")
  expect_identical(out$fid, exp$fid)
  expect_identical(out$ms$rt, exp$ms$rt)
  expect_equal(out$alignment$cross_check$engine, "gcalignr")
  expect_false(out$alignment$validated)
  expect_gt(out$alignment$score, 0.9)
  expect_named(out$processing$align_detectors, c("engine", "max_delay", "step"))
})

test_that("align_detectors() uses the engine option by default", {
  withr::local_options(moosaic.align_engine = "xcorr")
  expect_equal(align_detectors(mk_exp(0))$alignment$engine, "xcorr")
})

test_that("align_detectors() warns when the engines disagree by more than a scan", {
  exp <- mk_exp(0.05)
  local_mocked_bindings(
    .estimate_delay_gcalignr = \(...) 0.15
  )
  expect_warning(
    align_detectors(exp, engine = "xcorr"),
    class = "moosaic-warning-engine_disagreement"
  )
})

test_that("align_detectors() falls back to xcorr when GCalignR has too few peaks", {
  exp <- make_synthetic_run(
    n_comp = 1,
    centers = 5,
    widths = 0.04,
    spectra = list(spec(c(40, 41))),
    carbons = 1,
    delay = 0.05
  )
  expect_warning(
    out <- align_detectors(exp, engine = "gcalignr"),
    class = "moosaic-warning-engine_fallback"
  )
  expect_equal(out$alignment$engine, "xcorr")
  expect_true(is.na(out$alignment$cross_check$delay))
})

test_that("align_detectors() rejects non-experiments", {
  expect_error(align_detectors(list()), class = "moosaic-error-bad_argument")
})
