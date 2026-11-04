test_that(".extract_metadata() returns named list excluding structural attributes", {
  mat <- matrix(1:6, nrow = 2, ncol = 3)
  attr(mat, "sample_name") <- "test"
  attr(mat, "units") <- "pA"
  attr(mat, "dim") <- c(2, 3) # Should be excluded

  meta <- .extract_metadata(mat)
  expect_type(meta, "list")
  expect_named(meta)
  expect_true("sample_name" %in% names(meta))
  expect_true("units" %in% names(meta))
  expect_false("dim" %in% names(meta))
})

test_that(".standardize_fid() converts a matrix to internal list structure", {
  fid_mat <- matrix(c(0.001, 0.002, 0.003, 100, 200, 150), nrow = 3, ncol = 2)
  attr(fid_mat, "sample_name") <- "test"

  fid <- .standardize_fid(fid_mat)
  expect_type(fid, "list")
  expect_named(fid, c("rt", "intensity"))
  expect_length(fid$rt, 3)
  expect_length(fid$intensity, 3)
})

test_that(".standardize_fid() converts a data.frame", {
  fid_df <- data.frame(rt = c(0.001, 0.002), intensity = c(100, 200))
  fid <- .standardize_fid(fid_df)
  expect_type(fid, "list")
  expect_equal(fid$rt, c(0.001, 0.002))
})

test_that(".standardize_fid() aborts on wrong column count", {
  bad_mat <- matrix(1:6, nrow = 2, ncol = 3)
  expect_error(
    .standardize_fid(bad_mat),
    class = "moosaic-error-bad_format"
  )
})

test_that(".standardize_ms() handles long-format matrix", {
  ms_mat <- matrix(
    c(0.001, 0.001, 0.002, 0.002, 39.9, 40.1, 39.9, 40.1, 100, 200, 150, 250),
    ncol = 3,
    byrow = FALSE
  )
  colnames(ms_mat) <- c("rt", "mz", "intensity")

  ms <- .standardize_ms(ms_mat)
  expect_type(ms, "list")
  expect_named(ms, c("data", "rt", "tic"))
  expect_length(ms$rt, 2)
  expect_equal(ms$tic[1], 300) # 100 + 200
})

test_that(".standardize_ms() computes TIC correctly", {
  ms_mat <- matrix(
    c(0.001, 0.001, 0.002, 40, 40, 40, 100, 50, 75),
    ncol = 3,
    byrow = FALSE
  )
  colnames(ms_mat) <- c("rt", "mz", "intensity")

  ms <- .standardize_ms(ms_mat)
  expect_equal(ms$tic, c(150, 75))
})

test_that(".standardize_ms() aborts on missing columns", {
  bad_mat <- matrix(1:6, nrow = 3, ncol = 2)
  colnames(bad_mat) <- c("a", "b")
  expect_error(
    .standardize_ms(bad_mat),
    class = "moosaic-error-bad_format"
  )
})

test_that(".validate_gcms_fid_exp() accepts valid objects", {
  fid <- list(rt = c(0, 0.001), intensity = c(100, 150), metadata = list())
  ms <- list(
    data = matrix(c(0, 40, 100), nrow = 1, ncol = 3),
    rt = 0,
    tic = 100,
    metadata = list()
  )
  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )
  expect_invisible(.validate_gcms_fid_exp(exp))
})

test_that(".validate_gcms_fid_exp() aborts on rt not sorted", {
  fid <- list(rt = c(0.001, 0), intensity = c(100, 150), metadata = list())
  ms <- list(
    data = matrix(c(0, 40, 100), nrow = 1, ncol = 3),
    rt = 0,
    tic = 100,
    metadata = list()
  )
  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )
  expect_error(
    .validate_gcms_fid_exp(exp),
    class = "moosaic-error-bad_structure"
  )
})

test_that(".validate_gcms_fid_exp() aborts on rt/tic length mismatch", {
  fid <- list(rt = c(0, 0.001), intensity = c(100, 150), metadata = list())
  ms <- list(
    data = matrix(c(0, 40, 100), nrow = 1, ncol = 3),
    rt = c(0, 0.001),
    tic = c(100), # Wrong length
    metadata = list()
  )
  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )
  expect_error(
    .validate_gcms_fid_exp(exp),
    class = "moosaic-error-bad_structure"
  )
})

test_that("is_gcms_fid_exp() returns TRUE for valid objects", {
  fid <- list(rt = c(0, 0.001), intensity = c(100, 150), metadata = list())
  ms <- list(
    data = matrix(c(0, 40, 100), nrow = 1, ncol = 3),
    rt = 0,
    tic = 100,
    metadata = list()
  )
  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )
  expect_true(is_gcms_fid_exp(exp))
  expect_false(is_gcms_fid_exp(list()))
})

test_that("print.gcms_fid_exp() works on valid object", {
  fid <- list(
    rt = c(0, 0.001),
    intensity = c(100, 150),
    metadata = list(sample_name = "test_sample")
  )
  ms <- list(
    data = matrix(c(0, 40, 100), nrow = 1, ncol = 3),
    rt = c(0, 0.5),
    tic = c(100, 80),
    metadata = list()
  )
  exp <- .new_gcms_fid_exp(
    ms = ms,
    fid = fid,
    alignment = list(delay = 0, engine = NULL, score = NA, validated = FALSE),
    processing = list()
  )
  expect_output(print(exp), "GC-FID/MS Experiment")
})
