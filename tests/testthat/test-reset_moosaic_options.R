test_that("reset_moosaic_options() restores all defaults", {
  withr::local_options(moosaic.rank_max = 12L, moosaic.als_thresh = 0.1)
  reset_moosaic_options()
  expect_equal(getOption("moosaic.rank_max"), 6L)
  expect_equal(getOption("moosaic.als_thresh"), 0.001)
})
