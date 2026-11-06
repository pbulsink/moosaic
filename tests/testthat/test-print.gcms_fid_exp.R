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
