spec <- \(mz) setNames(rep(1, length(mz)), mz)

# Search mock: answers the i-th query (retention-time order) from `truth`
mock_by_order <- function(truth) {
  function(queries) {
    lapply(seq_along(queries), \(i) {
      df <- mk_hits(truth$name[i], 900, truth$formula[i], NA_real_)
      attr(df, "unknown_name") <- queries[[i]]$name
      df
    })
  }
}

test_that("synthetic run: truth is recovered from deconvolution to compound table", {
  withr::local_options(
    moosaic.background_component = FALSE,
    moosaic.als_thresh = 0.3
  )
  set.seed(4817)
  truth <- data.frame(
    name = c("n-heptane", "n-octane", "phenol"),
    formula = c("C7H16", "C8H18", "C6H6O"),
    rt = c(5, 10, 20),
    width = c(0.04, 0.05, 0.06)
  )
  exp <- make_synthetic_run(
    n_comp = 3,
    centers = truth$rt,
    widths = truth$width,
    spectra = list(
      spec(c(40, 41, 43)),
      spec(c(50, 51, 53)),
      spec(c(60, 61, 63))
    ),
    carbons = c(7, 8, 6),
    noise = 0.5,
    duration = 30
  )
  local_mocked_bindings(.run_mspepsearch = mock_by_order(truth))

  res <- suppressMessages(suppressWarnings(deconvolve_run(exp)))
  expect_length(res$components, 3L)
  res <- identify_components(res)
  expect_equal(
    vapply(res$components, \(x) x$name, ""),
    truth$name
  )
  res <- suppressMessages(
    quantify(res, sample_info("SYN", density = 0.8), style = "internal")
  )
  tbl <- total_compound_table(res)

  expect_equal(nrow(tbl), 3L)
  expect_equal(tbl$`Compound Name`, truth$name)
  expect_equal(tbl$`Compound Formula`, truth$formula)
  # Retention times within two MS scans of truth
  expect_lt(
    max(abs(as.numeric(tbl$`Retention Time`) - truth$rt)),
    2 * 0.27 / 60
  )
  # Gaussians of equal height: FID area is proportional to width
  ratio <- tbl$`Area (FID)` / truth$width
  expect_lt(max(ratio) / min(ratio) - 1, 0.1)
  # Internal-standard quantification sums to 100 wt%
  expect_equal(sum(res$peaks$wt_pct), 100, tolerance = 1e-6)
  expect_true(all(tbl$`Amount (ug/mL)` > 0))
})
