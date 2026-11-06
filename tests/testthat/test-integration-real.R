real_dir <- testthat::test_path("fixtures", "real_run")
real_ms <- file.path(real_dir, "data.ms")
real_fid <- file.path(real_dir, "FID1A.ch")
real_cal <- testthat::test_path("fixtures", "ri", "ONSITE.CAL")

nist_root <- "C:/NIST23/MSSEARCH"
# geopetro and w12main on this install hold only index stubs (no spectra) and
# make MSPepSearch exit with status 4, so they are left out.
nist_libs <- file.path(nist_root, c("mainlib", "replib", "nist_ri"))

# Compounds that must be found: formula, name stem, expected RT (min)
expected <- data.frame(
  formula = c("C6H6O", "C7H8O", "C8H18O", "C7H8O2", "C8H10O"),
  name = c("phenol", "2-methyl", "1-octanol", "2-methoxy", "2-ethyl"),
  rt = c(14.70, 18.46, 19.48, 19.96, 22.64)
)

test_that("real phenols-in-diesel run: process_sample() finds the target oxygenates", {
  skip_on_cran()
  skip_on_ci()
  # Takes about 36 minutes
  skip_if_not(file.exists(real_ms) && file.exists(real_fid), "real run absent")
  skip_if_not(all(dir.exists(nist_libs)), "NIST23 libraries not found")
  skip_if_not_installed("mspepsearchr")

  # gcalignr locks onto the search limit on dense diesel peak lists (see
  # Challenge Register); xcorr agrees with FID/TIC apex times to ~0.01 min.
  withr::local_options(
    moosaic.library_path = as.list(nist_libs),
    moosaic.align_engine = "xcorr"
  )

  info <- sample_info(
    "phenols-in-diesel",
    sample_name = "phenols-in-diesel",
    density = 0.85554,
    # 36 ppm water = 0.0036 wt%
    water_wt_pct = 36e-4
  )

  elapsed <- system.time(
    res <- suppressMessages(
      process_sample(
        real_ms,
        real_fid,
        info,
        ri_cal = real_cal,
        style = "internal"
      )
    )
  )[["elapsed"]]
  message("process_sample() runtime: ", round(elapsed, 1), " s")

  tbl <- total_compound_table(res)
  expect_gt(nrow(tbl), 0L)
  expect_equal(sum(res$peaks$wt_pct), 100, tolerance = 1e-6)

  rt <- as.numeric(tbl$`Retention Time`)
  for (i in seq_len(nrow(expected))) {
    e <- expected[i, ]
    hit <- !is.na(tbl$`Compound Formula`) &
      tbl$`Compound Formula` == e$formula &
      abs(rt - e$rt) <= 0.15
    expect_true(
      any(hit),
      label = sprintf("%s (%s) near %.2f min", e$name, e$formula, e$rt)
    )
  }

  snap <- tbl[, c("Peak No.", "Compound Name", "Retention Time")]
  expect_snapshot_value(as.data.frame(snap), style = "json2")
})
