test_that("specify_search_params() validates type via arg_match", {
  expect_error(
    specify_search_params(type = "bad_type"),
    "must be one of"
  )
})


test_that("specify_search_params() validates hits as positive integer", {
  expect_error(
    specify_search_params(hits = -1),
    class = "moosaic-error-bad_input"
  )
})


test_that("specify_search_params() sets valid parameters", {
  withr::local_options(
    moosaic.search_function = "identity",
    moosaic.search_hits = 10L,
    moosaic.search_threads = 1L
  )
  specify_search_params(type = "hybrid", hits = 15L, threads = 2L)
  expect_equal(getOption("moosaic.search_function"), "hybrid")
  expect_equal(getOption("moosaic.search_hits"), 15L)
  expect_equal(getOption("moosaic.search_threads"), 2L)
})


test_that("specify_search_params() validates ri_column_type via arg_match", {
  expect_error(
    specify_search_params(ri_column_type = "standard polar"),
    "must be one of"
  )
})


test_that("specify_search_params() sets a valid ri_column_type", {
  withr::local_options(moosaic.ri_column_type = "semi-standard non-polar")
  specify_search_params(ri_column_type = "standard non-polar")
  expect_equal(getOption("moosaic.ri_column_type"), "standard non-polar")
})
