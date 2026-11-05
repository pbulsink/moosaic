test_that(".moosaic_warn() produces both warning classes", {
  expect_warning(.moosaic_warn("careful", "foo"), class = "moosaic-warning-foo")
  expect_warning(.moosaic_warn("careful", "foo"), class = "moosaic-warning")
})

test_that(".moosaic_warn() works without a class and evaluates glue in the caller", {
  x <- 7
  expect_warning(.moosaic_warn("value {x}"), "value 7")
})
