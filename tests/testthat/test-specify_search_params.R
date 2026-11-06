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
  specify_search_params(type = "hybrid", hits = 15L, threads = 2L)
  expect_equal(getOption("moosaic.search_function"), "hybrid")
  expect_equal(getOption("moosaic.search_hits"), 15L)
  expect_equal(getOption("moosaic.search_threads"), 2L)
})
