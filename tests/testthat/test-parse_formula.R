test_that(".parse_formula() returns element counts", {
  expect_equal(.parse_formula("C10H22"), c(C = 10L, H = 22L))
  expect_equal(.parse_formula("CH4"), c(C = 1L, H = 4L))
  expect_equal(.parse_formula("C6H5Cl"), c(C = 6L, H = 5L, Cl = 1L))
  expect_equal(.parse_formula("C2H6O"), c(C = 2L, H = 6L, O = 1L))
})

test_that(".parse_formula() sums repeated elements and aborts on bad input", {
  expect_equal(.parse_formula("CH3CH3"), c(C = 2L, H = 6L))
  expect_error(.parse_formula("c6h6"), class = "moosaic-error-bad_formula")
  expect_error(.parse_formula(""), class = "moosaic-error-bad_formula")
  expect_error(
    .parse_formula(NA_character_),
    class = "moosaic-error-bad_formula"
  )
})
