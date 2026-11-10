test_that(".new_gcms_fid_exp() stores its parts under the gcms_fid_exp class without validating", {
  exp <- .new_gcms_fid_exp(ms = 1, fid = 2, alignment = 3, processing = 4)
  expect_s3_class(exp, "gcms_fid_exp")
  expect_equal(
    unclass(exp),
    list(ms = 1, fid = 2, alignment = 3, processing = 4)
  )
})
