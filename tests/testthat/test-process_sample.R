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
      ms = list(
        rt = c(0.1, 0.2, 0.3),
        data = cbind(
          rt = c(0.1, 0.2, 0.3),
          mz = c(40, 50, 60),
          intensity = c(100, 200, 150)
        )
      ),
      fid = list(rt = seq(0, 10, length.out = 100), intensity = rep(0, 100)),
      alignment = list(delay = 0.0123, engine = "xcorr")
    ),
    class = "gcms_fid_exp"
  )
  q <- mk_quantified()
  q$summary <- NULL
  local_mocked_bindings(
    read_experiment = mark("read", \(ms_file, fid_file) exp),
    `.search_fn` = function(type, call = rlang::caller_env()) {
      function(...) NULL
    },
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

test_that("process_sample() runs every stage in order and returns a summarised result", {
  calls <- mock_pipeline()
  withr::local_options(moosaic.library_path = list(tempdir()))
  out <- expect_no_warning(
    process_sample("a.ms", "a.ch", sample_info("S1"), style = "internal")
  )
  expect_equal(
    calls(),
    c("read", "align", "baseline", "deconvolve", "identify", "quantify")
  )
  expect_s3_class(out, "moosaic_result")
  expect_false(is.null(out$summary))
  expect_equal(out$quant$style, "internal")
})

test_that("process_sample() validates info before reading files", {
  withr::local_options(moosaic.library_path = list(tempdir()))
  expect_error(
    process_sample("a.ms", "a.ch", list()),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    process_sample("missing.ms", "missing.ch", sample_info("S1")),
    class = "moosaic-error-file_not_found"
  )
})

test_that("process_sample() rejects invalid verbose values before reading files", {
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
  expect_length(calls(), 0L)
})

test_that("process_sample() validates the search library before reading files", {
  calls <- mock_pipeline()
  withr::local_options(moosaic.library_path = list("missing-library"))

  expect_error(
    process_sample("a.ms", "a.ch", sample_info("S1")),
    class = "moosaic-error-missing_path"
  )
  expect_length(calls(), 0L)
})

test_that("process_sample() rejects an unset search library before reading", {
  calls <- mock_pipeline()
  withr::local_options(moosaic.library_path = NULL)

  expect_error(
    process_sample("a.ms", "a.ch", sample_info("S1")),
    class = "moosaic-error-missing_library"
  )
  expect_length(calls(), 0L)
})

test_that("process_sample() validates search package availability before reading", {
  calls <- mock_pipeline()
  withr::local_options(moosaic.library_path = list(tempdir()))
  local_mocked_bindings(
    `.search_fn` = function(type, call = rlang::caller_env()) {
      .moosaic_abort(
        "Package {.pkg mspepsearchr} is required for library searching.",
        class = "missing_package",
        call = call
      )
    }
  )

  expect_error(
    process_sample("a.ms", "a.ch", sample_info("S1")),
    class = "moosaic-error-missing_package"
  )
  expect_length(calls(), 0L)
})

test_that("process_sample() validates processing options before reading files", {
  calls <- mock_pipeline()
  withr::local_options(
    moosaic.library_path = list(tempdir()),
    moosaic.align_engine = "invalid"
  )

  expect_error(
    process_sample("a.ms", "a.ch", sample_info("S1")),
    class = "moosaic-error-unknown_engine"
  )
  expect_length(calls(), 0L)
})

test_that("process_sample() rejects invalid processing settings before reading", {
  calls <- mock_pipeline()
  invalid <- list(
    align_engine = "invalid",
    max_delay = 0,
    align_step = NA_real_,
    mz_min = 500,
    mz_bin = 0,
    fid_smooth_window = 2L,
    fid_baseline_method = "invalid",
    peak_min_height_snr = 0,
    window_padding = -1,
    window_merge_gap = -1,
    window_max_width = 0,
    window_max_peaks = 1.5,
    min_scans_per_window = 0L,
    rank_methods = "invalid",
    rank_max = 0L,
    svd_var_threshold = 0,
    pfr_cutoff = 1,
    pa_iterations = 0L,
    als_maxiter = 0L,
    als_thresh = 0,
    background_component = NA,
    als_unimodal = NA,
    ri_extrapolate = NA,
    ri_grace = -1,
    ri_penalty_per_unit = -1,
    disallowed_element_penalty = -1,
    element_penalties = c(N = -1),
    allowed_elements = NA_character_,
    search_hits = 0L,
    search_threads = 0L,
    ri_column_type = "invalid",
    min_match_factor = 1000,
    quant_style = "invalid"
  )

  for (option in names(invalid)) {
    opts <- c(
      list(moosaic.library_path = list(tempdir())),
      stats::setNames(list(invalid[[option]]), paste0("moosaic.", option))
    )
    withr::local_options(opts)
    expect_error(
      process_sample("a.ms", "a.ch", sample_info("S1"))
    )
    expect_length(calls(), 0L)
  }
})

test_that("process_sample() validates all stage arguments before reading files", {
  calls <- mock_pipeline()
  withr::local_options(moosaic.library_path = list(tempdir()))

  expect_error(
    process_sample("a.ms", "a.ch", sample_info("S1"), style = "invalid"),
    class = "rlang_error"
  )
  expect_error(
    process_sample(
      "a.ms",
      "a.ch",
      sample_info("S1"),
      include_solvents = NA
    ),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    process_sample(
      "a.ms",
      "a.ch",
      sample_info("S1"),
      ri_cal = data.frame(rt = c(2, 1), ri = c(100, 200))
    ),
    class = "moosaic-error-bad_calibration"
  )
  expect_length(calls(), 0L)
})

test_that("process_sample() is quiet when verbose is FALSE", {
  mock_pipeline()
  withr::local_options(moosaic.library_path = list(tempdir()))
  expect_silent(
    process_sample(
      "a.ms",
      "a.ch",
      sample_info("S1"),
      summarize = FALSE,
      verbose = FALSE
    )
  )
})

test_that("process_sample() can skip the report summary", {
  mock_pipeline()
  withr::local_options(moosaic.library_path = list(tempdir()))
  out <- expect_no_warning(
    process_sample("a.ms", "a.ch", sample_info("S1"), summarize = FALSE)
  )
  expect_null(out$summary)
})
