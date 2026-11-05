
test_that(".onLoad sets unset options but preserves pre-set values", {
  # Pre-set a custom value
  withr::local_options(moosaic.rank_max = 12L)
  # Simulate .onLoad
  .onLoad("moosaic", "moosaic")
  # Pre-set value should be preserved
  expect_equal(getOption("moosaic.rank_max"), 12L)
  # An unset option should now be set from defaults
  expect_equal(getOption("moosaic.als_thresh"), 0.001)
})

