test_that(".background_profile() is flat with maximum 1", {
  expect_equal(.background_profile(5), rep(1, 5))
})
