test_that("set_moosaic_options() sets named options and returns old values", {
  withr::local_options(moosaic.rank_max = 6L)
  old <- set_moosaic_options(rank_max = 10L, search_hits = 20L)
  expect_equal(getOption("moosaic.rank_max"), 10L)
  expect_equal(getOption("moosaic.search_hits"), 20L)
  expect_equal(old$moosaic.rank_max, 6L)
})

test_that("set_moosaic_options() aborts on unknown option", {
  expect_error(
    set_moosaic_options(unknown_option = 1),
    class = "moosaic-error-unknown_option"
  )
})

test_that("set_moosaic_options() with no args returns invisible list", {
  result <- set_moosaic_options()
  expect_type(result, "list")
})
