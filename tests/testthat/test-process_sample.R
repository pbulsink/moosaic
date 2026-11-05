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
    deconvolve_run = mark("deconvolve", \(exp) {
      structure(
        list(components = q$components, alignment = exp$alignment),
        class = "moosaic_result"
      )
    }),
    identify_components = mark("identify", \(result, ri_cal = NULL) {
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

test_that("process_sample() runs every stage in order and returns a summarised result", {
  calls <- mock_pipeline()
  out <- process_sample("a.ms", "a.ch", sample_info("S1"), style = "internal")
  expect_equal(
    calls(),
    c("read", "align", "baseline", "deconvolve", "identify", "quantify")
  )
  expect_s3_class(out, "moosaic_result")
  expect_false(is.null(out$summary))
  expect_equal(out$quant$style, "internal")
})

test_that("process_sample() validates info before reading files", {
  expect_error(
    process_sample("a.ms", "a.ch", list()),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    process_sample("missing.ms", "missing.ch", sample_info("S1")),
    class = "moosaic-error-file_not_found"
  )
})

test_that("process_sample() can skip the report summary", {
  mock_pipeline()
  out <- process_sample("a.ms", "a.ch", sample_info("S1"), summarize = FALSE)
  expect_null(out$summary)
})
