test_that("moosaic_options() returns only moosaic.* options", {
  withr::local_options(moosaic.rank_max = 8L, foo.bar = 1)
  opts <- moosaic_options()
  expect_true(all(startsWith(names(opts), "moosaic.")))
})
