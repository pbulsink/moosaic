mk_fid <- function(baseline, n = 2000, sd = 1) {
  set.seed(4821)
  rt <- seq(0, 10, length.out = n)
  list(rt = rt, intensity = baseline(rt) + stats::rnorm(n, sd = sd))
}

test_that(".check_fid_baseline() passes a flat baseline near zero", {
  fid <- mk_fid(\(t) 0 * t)
  expect_no_warning(out <- .check_fid_baseline(fid))
  expect_true(out$ok)
})

test_that(".check_fid_baseline() accepts a linear drift that starts at zero", {
  fid <- mk_fid(\(t) 2 * t)
  expect_no_warning(out <- .check_fid_baseline(fid))
  expect_equal(out$slope, 2, tolerance = 0.1)
})

test_that(".check_fid_baseline() warns on a baseline offset", {
  fid <- mk_fid(\(t) 50 + 0 * t)
  expect_warning(
    out <- .check_fid_baseline(fid),
    class = "moosaic-warning-fid_baseline_offset"
  )
  expect_false(out$ok)
})

test_that(".check_fid_baseline() warns on a curved baseline", {
  fid <- mk_fid(\(t) 40 * sin(pi * t / 10))
  expect_warning(
    .check_fid_baseline(fid),
    class = "moosaic-warning-fid_baseline_curved"
  )
})

test_that(".check_fid_baseline() ignores peaks sitting on a flat baseline", {
  fid <- mk_fid(\(t) 500 * exp(-((t - 5)^2) / 0.02))
  expect_no_warning(.check_fid_baseline(fid))
})

test_that(".check_fid_baseline() aborts on malformed or short input", {
  expect_error(
    .check_fid_baseline(list(rt = 1:3, intensity = 1:2)),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    .check_fid_baseline(list(rt = 1:5, intensity = 1:5)),
    class = "moosaic-error-bad_argument"
  )
})
