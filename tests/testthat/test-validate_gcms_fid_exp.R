
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

