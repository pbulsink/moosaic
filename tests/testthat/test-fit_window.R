test_that("fit_window() returns concentration, spectra, residuals and diagnostics", {
  d <- als_fixture(2)
  withr::local_options(moosaic.als_thresh = 0.3)
  fit <- fit_window(d$D, 2, d$C0)
  expect_named(fit, c("concentration", "spectra", "residuals", "diagnostics"))
  expect_equal(dim(fit$concentration), c(40L, 2L))
  expect_equal(dim(fit$spectra), c(30L, 2L))
  expect_equal(dim(fit$residuals), dim(d$D))
  expect_lt(fit$diagnostics$lack_of_fit, 5)
})

test_that("fit_window() aborts when rank and C0 disagree", {
  d <- als_fixture(2)
  expect_error(fit_window(d$D, 3, d$C0), class = "moosaic-error-bad_argument")
  expect_error(
    fit_window(d$D, 2, d$C0, background = TRUE),
    class = "moosaic-error-bad_argument"
  )
})

test_that("synthetic overlapping pair is recovered (stage)", {
  d <- als_fixture(2, noise = 0.5, seed = 4417)
  withr::local_options(moosaic.als_thresh = 0.3)
  fit <- fit_window(d$D, 2, d$C0)
  expect_lt(fit$diagnostics$lack_of_fit, 5)
  cosine <- function(a, b) sum(a * b) / sqrt(sum(a^2) * sum(b^2))
  cs <- outer(1:2, 1:2, Vectorize(\(i, j) cosine(fit$spectra[, i], d$S[, j])))
  expect_gt(max(cs[1, ]), 0.98)
  expect_gt(max(cs[2, ]), 0.98)
})
