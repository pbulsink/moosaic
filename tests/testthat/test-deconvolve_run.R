spec <- function(mz) {
  setNames(rep(1, length(mz)), mz)
}

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

test_that("deconvolve_run() recovers a crowded chain beyond the per-window rank cap", {
  withr::local_options(
    moosaic.background_component = FALSE,
    moosaic.rank_methods = "svd",
    moosaic.svd_var_threshold = 0.99,
    moosaic.window_max_width = 0.5,
    moosaic.window_max_peaks = 3L,
    moosaic.als_maxiter = 500L
  )
  centers <- seq(0.3, 1.4, by = 0.1)
  spectra <- lapply(seq_along(centers), function(i) {
    setNames(c(1, 0.5), c(40 + 2 * i, 41 + 2 * i))
  })
  exp <- make_synthetic_run(
    12,
    centers,
    rep(0.04, 12),
    spectra,
    rep(1, 12),
    duration = 1.7
  )
  res <- suppressMessages(deconvolve_run(exp, verbose = FALSE))
  expect_gt(nrow(res$windows), 1L)
  expect_length(res$components, 12L)
  rts <- sort(vapply(res$components, \(x) x$rt, numeric(1)))
  expect_equal(rts, centers, tolerance = 0.0045)
  expect_length(unique(vapply(res$components, \(x) x$id, character(1))), 12L)
  for (i in seq_along(centers)) {
    component <- res$components[[which.min(abs(
      rts[i] -
        vapply(
          res$components,
          \(x) x$rt,
          numeric(1)
        )
    ))]]
    recovered <- component$spectrum[names(spectra[[i]])]
    expect_equal(
      unname(recovered / max(recovered)),
      c(1, 0.5),
      tolerance = 0.05
    )
  }
})

test_that("deconvolve_run() handles no detected windows with verbose progress", {
  local_mocked_bindings(detect_peaks = \(...) {
    tibble::tibble(
      peak_id = integer(),
      apex_rt = numeric(),
      start_rt = numeric(),
      end_rt = numeric(),
      has_shoulder = logical()
    )
  })
  exp <- make_synthetic_run(
    1,
    0.3,
    0.04,
    list(spec(c(40, 41))),
    1,
    duration = 0.6
  )
  expect_message(res <- deconvolve_run(exp, verbose = TRUE), NA)
  expect_length(res$components, 0L)
})

test_that("deconvolve_run() validates arguments and displays optional progress", {
  expect_error(deconvolve_run(list()), class = "moosaic-error-bad_argument")
  exp <- make_synthetic_run(
    1,
    0.3,
    0.04,
    list(spec(c(40, 41))),
    1,
    duration = 0.6
  )
  expect_error(
    deconvolve_run(exp, verbose = NA),
    class = "moosaic-error-bad_argument"
  )
  withr::local_options(moosaic.background_component = FALSE)
  expect_message(
    invisible(capture.output(res <- deconvolve_run(exp, verbose = TRUE))),
    "Deconvoluting"
  )
  expect_length(res$components, 1L)
})
