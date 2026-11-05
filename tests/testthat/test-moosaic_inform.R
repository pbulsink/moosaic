test_that(".moosaic_inform() emits a message with both classes", {
  expect_message(
    .moosaic_inform("hello", "foo"),
    class = "moosaic-message-foo"
  )
  expect_message(.moosaic_inform("hello", "foo"), class = "moosaic-message")
})

test_that(".moosaic_inform() works without a class and evaluates glue in the caller", {
  x <- 5
  expect_message(.moosaic_inform("value {x}"), "value 5")
})
