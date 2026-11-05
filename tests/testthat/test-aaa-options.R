test_that(".moosaic_default_options() returns a named list with all expected keys", {
  opts <- .moosaic_default_options()
  expect_type(opts, "list")
  expect_named(opts)

  # Check a sample of keys exist
  expected_keys <- c(
    "moosaic.library_path",
    "moosaic.search_function",
    "moosaic.rank_max",
    "moosaic.als_thresh"
  )
  expect_true(all(expected_keys %in% names(opts)))
})

