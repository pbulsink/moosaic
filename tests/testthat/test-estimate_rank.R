spec <- \(mz) setNames(rep(1, length(mz)), mz)

mk_run <- \(noise) {
  make_synthetic_run(
    n_comp = 3,
    centers = c(5, 10, 10.06),
    widths = rep(0.04, 3),
    spectra = list(spec(c(40, 41)), spec(c(50, 51)), spec(c(60, 61))),
    carbons = 1:3,
    noise = noise,
    seed = 3318,
    duration = 11
  )
}

rank_window <- \(exp, start, end) {
  w <- list(window_id = 1L, start_rt = start, end_rt = end)
  estimate_rank(
    extract_ms_matrix(exp, w)$D,
    .extract_fid_window(exp, w),
    max_rank = 6
  )
}

test_that("estimate_rank() recovers the rank of noiseless data with full agreement", {
  for (k in 1:3) {
    set.seed(3011 + k)
    x <- make_lowrank(k)
    out <- estimate_rank(x$D, x$fid)
    expect_equal(out$rank, k)
    expect_equal(out$confidence, 1)
    expect_named(out$votes, c("fid", "svd", "bic"))
  }
})

test_that("estimate_rank() skips parallel analysis when the other methods agree", {
  pa_calls <- 0L
  local_mocked_bindings(.rank_pa = \(...) {
    pa_calls <<- pa_calls + 1L
    99L
  })
  x <- make_lowrank(2)
  out <- estimate_rank(x$D, x$fid)
  expect_equal(pa_calls, 0L)
  expect_length(out$votes, 3L)
  expect_false("pa" %in% names(out$votes))
  expect_equal(out$rank, 2L)
})

test_that("estimate_rank() runs parallel analysis when the other methods disagree", {
  withr::local_options(moosaic.pa_iterations = 5L)
  pa_calls <- 0L
  local_mocked_bindings(
    .rank_fid = \(...) 1L,
    .rank_svd = \(...) 2L,
    .rank_bic = \(...) 2L,
    .rank_pa = \(...) {
      pa_calls <<- pa_calls + 1L
      2L
    }
  )
  x <- make_lowrank(2)
  out <- estimate_rank(x$D, x$fid)
  expect_equal(pa_calls, 1L)
  expect_length(out$votes, 4L)
  expect_named(out$votes, c("fid", "svd", "bic", "pa"))
  expect_equal(out$rank, 2L)
  expect_equal(out$confidence, 0.75)
})

test_that("estimate_rank() runs parallel analysis when too few other votes are usable", {
  pa_calls <- 0L
  local_mocked_bindings(.rank_pa = \(...) {
    pa_calls <<- pa_calls + 1L
    2L
  })
  out <- estimate_rank(make_lowrank(2)$D, methods = c("svd", "pa"))
  expect_equal(pa_calls, 1L)
  expect_named(out$votes, c("svd", "pa"))
  out2 <- estimate_rank(make_lowrank(2)$D, methods = "pa")
  expect_named(out2$votes, "pa")
})

test_that("estimate_rank() compares capped votes when deciding to skip", {
  pa_calls <- 0L
  local_mocked_bindings(
    .rank_svd = \(...) 4L,
    .rank_bic = \(...) 5L,
    .rank_pa = \(...) {
      pa_calls <<- pa_calls + 1L
      1L
    }
  )
  out <- estimate_rank(make_lowrank(3)$D, methods = c("svd", "bic", "pa"), max_rank = 3)
  expect_equal(pa_calls, 0L)
  expect_equal(out$rank, 3L)
})

test_that("estimate_rank() caps rank and votes at max_rank", {
  withr::local_options(moosaic.pa_iterations = 10L)
  set.seed(3020)
  x <- make_lowrank(3)
  out <- estimate_rank(x$D, x$fid, max_rank = 2)
  expect_equal(out$rank, 2L)
  expect_true(all(out$votes <= 2))
})

test_that("estimate_rank() reduces max_rank to the smallest dimension with a message", {
  D <- make_lowrank(2, n_scan = 5, n_mz = 4)$D
  expect_message(
    out <- estimate_rank(D, methods = "svd", max_rank = 10),
    class = "moosaic-message-max_rank_reduced"
  )
  expect_lte(out$rank, 4L)
})

test_that("estimate_rank() reports rank 1 with zero confidence and a message for pure noise", {
  withr::local_options(moosaic.pa_iterations = 10L)
  set.seed(8851)
  D <- matrix(rnorm(1200), 40)
  fid <- list(rt = seq_len(40) * 0.0045, intensity = rnorm(40))
  expect_message(
    out <- estimate_rank(D, fid),
    class = "moosaic-message-no_signal"
  )
  expect_equal(out$rank, 1L)
  expect_equal(out$confidence, 0)
})

test_that("estimate_rank() reads default methods from options and runs a subset without fid", {
  withr::local_options(moosaic.rank_methods = c("svd", "bic"))
  out <- estimate_rank(make_lowrank(2)$D)
  expect_named(out$votes, c("svd", "bic"))
  expect_equal(out$rank, 2L)
  out2 <- estimate_rank(make_lowrank(2)$D, methods = "svd")
  expect_named(out2$votes, "svd")
})

test_that("estimate_rank() treats an unusable fid vote as missing", {
  x <- make_lowrank(2, n_scan = 4L)
  out <- estimate_rank(x$D, x$fid, methods = c("fid", "svd", "bic"))
  expect_true(is.na(out$votes[["fid"]]))
  expect_gte(out$confidence, 0)
  expect_lte(out$confidence, 1)
})

test_that("estimate_rank() validates its inputs", {
  x <- make_lowrank(1)
  expect_error(
    estimate_rank(x$D, x$fid, methods = c("svd", "magic")),
    class = "moosaic-error-unknown_method"
  )
  expect_error(
    estimate_rank(x$D, methods = c("fid", "svd")),
    class = "moosaic-error-missing_fid"
  )
  expect_error(
    estimate_rank(x$D, list(rt = 1:3, intensity = 1:3), methods = "fid"),
    class = "moosaic-error-bad_argument"
  )
  expect_error(estimate_rank(1:10), class = "moosaic-error-bad_argument")
  expect_error(
    estimate_rank(matrix(c(1, NA, 2, 3), 2)),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    estimate_rank(x$D, x$fid, max_rank = 0),
    class = "moosaic-error-bad_argument"
  )
})

test_that("estimate_rank() matches the truth on synthetic windows at low noise", {
  skip_on_cran()
  exp <- mk_run(noise = 1)
  withr::local_options(moosaic.pa_iterations = 10L)
  set.seed(7741)
  isolated <- rank_window(exp, 4.85, 5.15)
  pair <- rank_window(exp, 9.8, 10.3)
  expect_equal(isolated$rank, 1L)
  expect_equal(pair$rank, 2L)
  expect_gte(pair$confidence, 0.5)
})

test_that("estimate_rank() returns a well-formed result at medium noise", {
  skip_on_cran()
  exp <- mk_run(noise = 30)
  withr::local_options(moosaic.pa_iterations = 10L)
  set.seed(7742)
  pair <- rank_window(exp, 9.8, 10.3)
  expect_true(pair$rank >= 1L && pair$rank <= 6L)
  expect_true(pair$confidence >= 0 && pair$confidence <= 1)
  expect_true(all(c("fid", "svd", "bic") %in% names(pair$votes)))
})
