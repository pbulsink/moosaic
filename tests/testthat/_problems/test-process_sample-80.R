# Extracted from test-process_sample.R:80

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "moosaic", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
mock_pipeline <- function(env = parent.frame()) {
  calls <- character()
  mark <- \(nm, f) {
    force(nm)
    force(f)
    \(...) {
      calls <<- c(calls, nm)
      f(...)
    }
  }
  exp <- structure(
    list(
      fid = list(rt = seq(0, 10, length.out = 100), intensity = rep(0, 100)),
      alignment = list(delay = 0.0123)
    ),
    class = "gcms_fid_exp"
  )
  q <- mk_quantified()
  q$summary <- NULL
  local_mocked_bindings(
    read_experiment = mark("read", \(ms_file, fid_file) exp),
    align_detectors = mark("align", \(exp, ...) exp),
    .check_fid_baseline = mark("baseline", \(fid, ...) invisible(NULL)),
    deconvolve_run = mark("deconvolve", \(exp, verbose) {
      structure(
        list(components = q$components, alignment = exp$alignment),
        class = "moosaic_result"
      )
    }),
    identify_components = mark("identify", \(result, ri_cal = NULL, verbose) {
      result$identifications <- tibble::tibble()
      result
    }),
    quantify = mark(
      "quantify",
      \(result, info, style = NULL, reference_peak = NULL) {
        q$quant$style <- style
        q
      }
    ),
    .env = env
  )
  \() calls
}

# test -------------------------------------------------------------------------
calls <- mock_pipeline()
for (verbose in list(NA, NULL, 1, "TRUE", c(TRUE, FALSE))) {
  expect_error(
    process_sample(
      "a.ms",
      "a.ch",
      sample_info("S1"),
      verbose = verbose
    ),
    class = "moosaic-error-bad_argument"
  )
}
