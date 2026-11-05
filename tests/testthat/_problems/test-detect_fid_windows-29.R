# Extracted from test-detect_fid_windows.R:29

# prequel ----------------------------------------------------------------------
spec <- \(mz) setNames(rep(1, length(mz)), mz)

# test -------------------------------------------------------------------------
exp <- make_synthetic_run(
    n_comp = 1,
    centers = 5,
    widths = 0.04,
    spectra = list(spec(c(40, 41))),
    carbons = 1
  )
withr::local_options(moosaic.min_scans_per_window = 10000L)
expect_warning(detect_fid_windows(exp), class = "moosaic-warning-few_scans")
