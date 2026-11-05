
test_that(".get_moosaic_option() reads a valid option", {
  withr::local_options(moosaic.rank_max = 8L)
  val <- .get_moosaic_option("rank_max")
  expect_equal(val, 8L)
})


test_that(".get_moosaic_option() aborts on unknown option", {
  expect_error(
    .get_moosaic_option("unknown_thing"),
    class = "moosaic-error-unknown_option"
  )
})

