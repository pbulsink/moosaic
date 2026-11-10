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
