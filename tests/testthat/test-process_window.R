spec <- function(mz) {
  setNames(rep(1, length(mz)), mz)
}

mk_pair <- function() {
  make_synthetic_run(
    n_comp = 2,
    centers = c(10, 10.07),
    widths = c(0.04, 0.04),
    spectra = list(spec(c(40, 41, 42)), spec(c(50, 51, 52))),
    carbons = 1:2
  )
}
pair_window <- list(window_id = 1L, start_rt = 9.85, end_rt = 10.22)

test_that("process_window() recovers an overlapping synthetic pair", {
  withr::local_options(
    moosaic.background_component = FALSE,
    moosaic.als_thresh = 0.3
  )
  set.seed(7321)
  comps <- suppressMessages(process_window(pair_window, mk_pair()))
  expect_length(comps, 2L)
  scan <- 0.27 / 60
  rts <- vapply(comps, \(x) x$rt, numeric(1))
  expect_lt(abs(min(rts) - 10), scan * 1.5)
  expect_lt(abs(max(rts) - 10.07), scan * 1.5)
  expect_false(any(vapply(comps, \(x) x$is_background, logical(1))))
  expect_true(all(vapply(comps, \(x) x$area_fid > 0, logical(1))))
})

test_that("process_window() adds an optional background component", {
  withr::local_options(
    moosaic.background_component = TRUE,
    moosaic.als_thresh = 0.3
  )
  set.seed(7322)
  comps <- suppressMessages(process_window(pair_window, mk_pair()))
  expect_length(comps, 3L)
  expect_true(comps[[3]]$is_background)
})

test_that("process_window() rejects a bad exp", {
  expect_error(
    process_window(pair_window, 1),
    class = "moosaic-error-bad_argument"
  )
})

test_that("deconvolve_run() processes every FID window into a moosaic_result", {
  withr::local_options(
    moosaic.background_component = FALSE,
    moosaic.als_thresh = 0.3
  )
  set.seed(7323)
  exp <- make_synthetic_run(
    n_comp = 2,
    centers = c(5, 10),
    widths = c(0.04, 0.04),
    spectra = list(spec(c(40, 41)), spec(c(50, 51))),
    carbons = 1:2
  )
  res <- suppressMessages(suppressWarnings(deconvolve_run(exp)))
  expect_s3_class(res, "moosaic_result")
  expect_named(res, c("components", "windows"))
  expect_equal(nrow(res$windows), 2L)
  expect_length(res$components, 2L)
  expect_equal(nrow(components_to_tibble(res)), 2L)
})

test_that("process_window() copes with a window of only a few scans", {
  withr::local_options(moosaic.background_component = TRUE)
  tiny <- list(window_id = 1L, start_rt = 10, end_rt = 10 + 3.5 * 0.27 / 60)
  comps <- suppressMessages(suppressWarnings(process_window(tiny, mk_pair())))
  expect_true(length(comps) >= 1L)
})
