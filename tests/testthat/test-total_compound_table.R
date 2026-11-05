test_that("total_compound_table() returns the report columns in order", {
  tbl <- total_compound_table(mk_quantified())
  expect_s3_class(tbl, "tbl_df")
  expect_equal(
    names(tbl),
    c(
      "Peak No.",
      "Compound Name",
      "Retention Time",
      "Compound Formula",
      "Compound Molar Mass",
      "Area (FID)",
      "Amount (ug/mL)",
      "Target or Relative",
      "MS Match Score",
      "Area (MS)",
      "FID/MS Ratio",
      "Rank Confidence",
      "RI Delta",
      "Final Score"
    )
  )
  expect_equal(nrow(tbl), 4L)
})

test_that("total_compound_table() fills values from the peaks", {
  x <- mk_quantified()
  tbl <- total_compound_table(x)
  expect_equal(tbl$`Peak No.`, 1:4)
  expect_equal(tbl$`Compound Name`[1], "n-heptane")
  expect_equal(tbl$`Retention Time`[1], "3")
  expect_equal(tbl$`Compound Molar Mass`[1], round(x$peaks$mw[1], 3))
  expect_equal(tbl$`Area (FID)`, x$peaks$area)
  expect_equal(tbl$`Amount (ug/mL)`, round(x$peaks$amount_ug_ml, 3))
  expect_equal(sum(tbl$`Target or Relative` == "Target"), 1L)
  expect_equal(tbl$`MS Match Score`, rep(900, 4))
  expect_equal(tbl$`Final Score`, rep(895, 4))
  expect_equal(tbl$`RI Delta`, rep(-1, 4))
})

test_that("total_compound_table() carries area_ms, ratio and rank confidence", {
  x <- mk_quantified()
  expect_equal(total_compound_table(x)$`Area (MS)`, rep(1, 4))
  expect_equal(total_compound_table(x)$`FID/MS Ratio`, rep(1, 4))
  expect_true(all(is.na(total_compound_table(x)$`Rank Confidence`)))
  x$peaks$rank_confidence <- c(1, 0.5, 1, 1)
  expect_equal(total_compound_table(x)$`Rank Confidence`, c(1, 0.5, 1, 1))
})

test_that("total_compound_table() requires a quantified result", {
  expect_error(total_compound_table(1), class = "moosaic-error-bad_argument")
  res <- structure(list(components = list()), class = "moosaic_result")
  expect_error(total_compound_table(res), class = "moosaic-error-not_quantified")
})
