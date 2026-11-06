test_that("summarize_report() requires a quantified result", {
  expect_error(summarize_report(1), class = "moosaic-error-bad_argument")
  res <- structure(list(components = list()), class = "moosaic_result")
  expect_error(summarize_report(res), class = "moosaic-error-not_quantified")
})

test_that("summarize_report() builds family totals that exclude solvents", {
  out <- mk_quantified()
  fam <- out$summary$families
  expect_equal(names(fam), c("compound_type", "wt_pct"))
  expect_equal(nrow(fam), 8L)
  p <- out$peaks
  expect_equal(fam$wt_pct[fam$compound_type == "Paraffin"], sum(p$wt_pct[1:2]))
  expect_equal(fam$wt_pct[fam$compound_type == "Oxygenate"], p$wt_pct[3])
  expect_equal(sum(fam$wt_pct), sum(p$wt_pct[1:3]))
})

test_that("summarize_report() can include solvents", {
  base <- mk_quantified()
  p <- base$peaks
  out <- summarize_report(base, include_solvents = TRUE)
  expect_equal(sum(out$summary$families$wt_pct), sum(p$wt_pct))
  expect_true(out$summary$include_solvents)
})

test_that("summarize_report() computes recovery and totals", {
  out <- mk_quantified()
  t <- out$summary$totals
  p <- out$peaks
  expect_equal(t$gc_recovery, sum(p$wt_pct[1:3]))
  expect_equal(t$methanol, 2)
  expect_equal(t$water, 1)
  expect_equal(t$total, t$gc_recovery + 3)
  expect_equal(t$element_sum, 100)
})

test_that("summarize_report() excludes methanol from recovery only when it is added", {
  base <- mk_quantified()
  p <- base$peaks
  p$name[1] <- "Methanol"
  base$peaks <- p
  with_meoh <- summarize_report(base)
  expect_equal(with_meoh$summary$totals$gc_recovery, sum(p$wt_pct[2:3]))
})

test_that("summarize_report() gives element weights that follow the formulas", {
  out <- mk_quantified()
  el <- out$summary$elements
  expect_equal(
    el$element,
    c("Carbon", "Hydrogen", "Nitrogen", "Oxygen", "Sulfur")
  )
  expect_equal(sum(el$wt_pct), 100)
  expect_equal(el$wt_pct[el$element == "Nitrogen"], 0)
  expect_gt(el$wt_pct[el$element == "Oxygen"], 0)
})

test_that("summarize_report() summarises peak origins and the alignment offset", {
  out <- mk_quantified()
  q <- out$summary$qc
  expect_equal(q$total_peaks, 4L)
  expect_equal(q$aligned_peaks, 4L)
  expect_equal(q$unique_peaks, 0L)
  expect_equal(q$interpolated_peaks, 0L)
  expect_equal(q$ms_fid_offset, 0.0123)
})

test_that("summarize_report() reports a missing alignment as NA", {
  base <- mk_quantified()
  base$alignment <- NULL
  expect_true(is.na(summarize_report(base)$summary$qc$ms_fid_offset))
})

test_that("summarize_report() leaves element totals at zero when nothing is quantified", {
  base <- mk_quantified()
  base$peaks$wt_pct <- NA_real_
  out <- summarize_report(base)
  expect_equal(out$summary$elements$wt_pct, rep(0, 5))
})
