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
