test_that(".moosaic_abort() produces moosaic-error class", {
  expect_error(
    .moosaic_abort("test error", "test_class"),
    class = "moosaic-error-test_class"
  )
})
