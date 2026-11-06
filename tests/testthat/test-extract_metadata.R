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
