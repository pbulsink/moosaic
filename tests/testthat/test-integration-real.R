real_dir <- testthat::test_path("fixtures", "real_run")
real_ms <- file.path(real_dir, "phenols.ms")
real_fid <- file.path(real_dir, "phenols.ch")
real_cal <- testthat::test_path("fixtures", "ri", "ONSITE.CAL")

test_that("real phenols run: process_sample() produces a sane compound table", {
  skip_on_cran()
  skip_if_not(file.exists(real_ms) && file.exists(real_fid), "real run absent")
  skip_if_not(
    nzchar(Sys.getenv("MOOSAIC_LIBRARY_PATH")) ||
      length(getOption("moosaic.library_path")) > 0,
    "no spectral library configured"
  )

  elapsed <- system.time(
    res <- suppressMessages(
      process_sample(
        real_ms,
        real_fid,
        sample_info("PHENOLS", density = 1),
        ri_cal = real_cal,
        style = "internal"
      )
    )
  )[["elapsed"]]
  message("process_sample() runtime: ", round(elapsed, 1), " s")

  tbl <- total_compound_table(res)
  expect_gt(nrow(tbl), 0L)
  expect_equal(sum(res$peaks$wt_pct), 100, tolerance = 1e-6)
  expect_true(any(!is.na(tbl$`Compound Name`)))

  snap <- tbl[, c("Peak No.", "Compound Name", "Retention Time")]
  expect_snapshot_value(as.data.frame(snap), style = "json2")
})
