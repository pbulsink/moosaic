
test_that("specify_identification_penalties() sets penalties", {
  specify_identification_penalties(
    ri_grace = 15,
    element_penalties = c(N = 60, S = 60)
  )
  expect_equal(getOption("moosaic.ri_grace"), 15)
  expect_equal(getOption("moosaic.element_penalties")["N"], c(N = 60))
})


test_that("specify_identification_penalties() sets and validates disallowed_element_penalty", {
  withr::local_options(moosaic.disallowed_element_penalty = 100)
  specify_identification_penalties(disallowed_element_penalty = 250)
  expect_equal(getOption("moosaic.disallowed_element_penalty"), 250)
  expect_error(
    specify_identification_penalties(disallowed_element_penalty = -1),
    class = "moosaic-error-bad_input"
  )
  expect_error(
    specify_identification_penalties(disallowed_element_penalty = "a"),
    class = "moosaic-error-bad_input"
  )
})
