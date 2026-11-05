info <- sample_info("S1", density = 0.8)

# True masses m_i give FID (Polyarc) areas proportional to m_i * C_i / M_i
truth_run <- function() {
  f <- c("C7H16", "C8H18", "C6H6O", "C10H22")
  nm <- c("n-heptane", "n-octane", "phenol", "n-decane")
  m <- c(1, 2, 3, 4)
  mw <- .molecular_weight(lapply(f, .parse_formula))
  C <- .carbon_count(lapply(f, .parse_formula))
  list(
    m = m,
    res = mk_qresult(
      rt = c(3, 5, 8, 12),
      area = 1000 * m * C / mw,
      name = nm,
      formula = f,
      ri = c(700, 800, 959, 1000)
    )
  )
}

test_that("quantify() recovers known mass fractions and sums to 100 wt%", {
  tr <- truth_run()
  out <- quantify(tr$res, info, style = "internal")
  expect_s3_class(out, "moosaic_result")
  expect_equal(out$peaks$wt_pct, tr$m / sum(tr$m) * 100)
  expect_equal(sum(out$peaks$wt_pct), 100)
  expect_equal(sum(out$peaks$amount_ug_ml), 1e6 * info$density)
  expect_equal(out$quant$style, "internal")
})

test_that("quantify() marks the reference peak as the target", {
  tr <- truth_run()
  out <- quantify(tr$res, info, style = "internal")
  expect_equal(
    out$peaks$quant_basis,
    c("Relative", "Relative", "Relative", "Target")
  )
  expect_equal(out$quant$reference_peak, "c4")
})

test_that("quantify() honours an explicit reference peak", {
  tr <- truth_run()
  out <- quantify(tr$res, info, style = "internal", reference_peak = "c2")
  expect_equal(out$peaks$quant_basis[2], "Target")
  expect_equal(out$peaks$wt_pct, tr$m / sum(tr$m) * 100)
})

test_that("quantify() reads the default style from the option", {
  withr::local_options(moosaic.quant_style = "internal")
  expect_equal(quantify(truth_run()$res, info)$quant$style, "internal")
})

test_that("quantify() adds family and solvent flags", {
  out <- quantify(truth_run()$res, info, style = "internal")
  expect_equal(
    out$peaks$family,
    c("Paraffin", "Paraffin", "Oxygenate", "Paraffin")
  )
  expect_equal(out$peaks$solvent, rep(FALSE, 4))
})

test_that("quantify() quantifies unidentified peaks through interpolated formulas", {
  tr <- truth_run()
  res <- mk_qresult(
    rt = c(3, 5, 8),
    area = c(10, 12, 20),
    name = c("n-heptane", NA, "n-nonane"),
    formula = c("C7H16", NA, "C9H20"),
    ri = c(700, 800, 900)
  )
  out <- quantify(res, info, style = "internal")
  expect_equal(out$peaks$origin, c("library", "interpolated", "library"))
  expect_false(anyNA(out$peaks$amount_ug_ml))
  expect_equal(sum(out$peaks$wt_pct), 100)
})

test_that("quantify() with an external curve scales targets and ratios non-targets", {
  f <- c("C7H16", "C8H18", "C6H6O")
  res <- mk_qresult(
    rt = c(3, 5, 8),
    area = c(50000, 60000, 40000),
    name = c("n-heptane", "n-octane", "phenol"),
    formula = f,
    ri = c(700, 800, 959)
  )
  dil <- sample_info("S2", dilution = 2)
  out <- quantify(res, dil, style = "slope")
  curves <- .fit_calibration(calibration_points, "slope")
  expected_hept <- 50000 * curves$slope[curves$target == "n-heptane"] * 2
  expected_phenol <- 40000 * curves$slope[curves$target == "phenol"] * 2
  mw <- .molecular_weight(lapply(f, .parse_formula))
  expect_equal(out$peaks$amount_ug_ml[1], expected_hept)
  expect_equal(out$peaks$amount_ug_ml[3], expected_phenol)
  expect_equal(
    out$peaks$amount_ug_ml[2],
    expected_hept * (60000 / 50000) * (7 / 8) * (mw[2] / mw[1])
  )
  expect_equal(out$peaks$quant_basis, c("Target", "Relative", "Target"))
  expect_equal(
    out$peaks$calibration_target,
    c("n-heptane", "n-heptane", "phenol")
  )
})

test_that("quantify() aborts when no calibration target is present for an external curve", {
  res <- mk_qresult(
    rt = c(3, 5),
    area = c(10, 20),
    name = c("n-octane", "n-decane"),
    formula = c("C8H18", "C10H22"),
    ri = c(800, 1000)
  )
  expect_error(
    quantify(res, info, style = "slope"),
    class = "moosaic-error-no_calibration_targets"
  )
})

test_that("quantify() validates its inputs", {
  tr <- truth_run()
  expect_error(quantify(1, info), class = "moosaic-error-bad_argument")
  expect_error(quantify(tr$res, list()), class = "moosaic-error-bad_argument")
  expect_error(quantify(tr$res, info, style = "cubic"))
  expect_error(
    quantify(tr$res, info, style = "internal", reference_peak = "zz"),
    class = "moosaic-error-bad_argument"
  )
  zero <- tr$res
  zero$components[[1]]$area_fid <- 0
  expect_error(
    quantify(zero, info, style = "internal", reference_peak = "c1"),
    class = "moosaic-error-bad_argument"
  )
  unid <- tr$res
  unid$identifications <- NULL
  expect_error(quantify(unid, info), class = "moosaic-error-not_identified")
})

test_that("quantify() aborts without components or a usable reference peak", {
  empty <- structure(
    list(components = list(), identifications = tibble::tibble()),
    class = "moosaic_result"
  )
  expect_error(quantify(empty, info), class = "moosaic-error-no_components")
  none <- mk_qresult(c(3, 5), c(10, 20), c(NA, NA), c(NA, NA))
  expect_error(
    suppressWarnings(quantify(none, info, style = "internal")),
    class = "moosaic-error-no_reference_peak"
  )
})
