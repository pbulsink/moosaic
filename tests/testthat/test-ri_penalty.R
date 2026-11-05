test_that(".ri_penalty() is zero within grace and linear beyond it", {
  out <- .ri_penalty(
    c(1000, 1000, 1000),
    c(1005, 1025, 975),
    grace = 10,
    per_unit = 1
  )
  expect_equal(out$penalty, c(0, 15, 15))
  expect_equal(out$ri_missing, c(FALSE, FALSE, FALSE))
})

test_that(".ri_penalty() scales by per_unit", {
  expect_equal(.ri_penalty(1000, 1030, 10, 2)$penalty, 40)
})

test_that(".ri_penalty() gives 0 and a flag when an RI is missing", {
  out <- .ri_penalty(c(1000, NA), c(NA, 900), grace = 10, per_unit = 1)
  expect_equal(out$penalty, c(0, 0))
  expect_equal(out$ri_missing, c(TRUE, TRUE))
})
