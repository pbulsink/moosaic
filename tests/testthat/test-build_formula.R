test_that(".build_formula() writes Hill-style C, H, O formulas", {
  expect_equal(
    .build_formula(c(8, 1, 2), c(18, 4, 6), c(0, 0, 1)),
    c("C8H18", "CH4", "C2H6O")
  )
  expect_equal(.build_formula(6, 6, 1), "C6H6O")
})
