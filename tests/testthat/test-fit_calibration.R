pts <- tibble::tibble(
  target = rep(c("a", "b"), each = 4),
  level = rep(1:4, 2),
  conc = c(2, 4, 6, 8, 1, 2, 3, 4),
  resp = c(1, 2, 3, 4, 1, 2, 3, 4)
)

test_that(".fit_calibration() fits one curve per target", {
  out <- .fit_calibration(pts, "slope")
  expect_equal(out$target, c("a", "b"))
  expect_equal(out$slope, c(2, 1))
  expect_equal(out$intercept, c(0, 0))
  expect_equal(out$r2, c(1, 1))
  expect_equal(out$n_points, c(4L, 4L))
})

test_that(".fit_calibration() fits an intercept for slope_intercept", {
  p <- pts
  p$conc[1:4] <- p$conc[1:4] + 5
  out <- .fit_calibration(p, "slope_intercept")
  expect_equal(out$intercept[1], 5)
  expect_equal(out$slope[1], 2)
})

test_that(".fit_calibration() fits a quadratic term", {
  p <- tibble::tibble(
    target = "a",
    conc = 1 + 2 * (1:5) + 0.5 * (1:5)^2,
    resp = as.numeric(1:5)
  )
  out <- .fit_calibration(p, "quadratic")
  expect_equal(c(out$intercept, out$slope, out$quad), c(1, 2, 0.5))
})

test_that(".fit_calibration() excludes zero-response and missing points", {
  p <- pts[pts$target == "a", ]
  p$resp[1] <- 0
  p$conc[2] <- NA
  out <- .fit_calibration(p, "slope")
  expect_equal(out$n_points, 2L)
  expect_equal(out$slope, 2)
})

test_that(".fit_calibration() gives NA coefficients when a curve cannot be fitted", {
  p <- tibble::tibble(target = "a", conc = c(1, 2), resp = c(1, 2))
  out <- .fit_calibration(p, "quadratic")
  expect_true(is.na(out$slope))
  expect_true(is.na(out$r2))
})

test_that(".fit_calibration() rejects an unknown style", {
  expect_error(.fit_calibration(pts, "cubic"))
})

test_that(".fit_calibration() gives NA r2 when the concentrations do not vary", {
  p <- tibble::tibble(target = "a", conc = c(5, 5, 5), resp = c(1, 2, 3))
  out <- .fit_calibration(p, "slope_intercept")
  expect_true(is.na(out$r2))
})
