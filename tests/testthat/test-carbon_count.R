test_that(".carbon_count() returns the number of carbon atoms", {
  expect_equal(.carbon_count(.parse_formula("C6H5Cl")), 6)
  expect_equal(.carbon_count(.parse_formula("H2O")), 0)
})

test_that(".carbon_count() is vectorised over a list of counts", {
  expect_equal(
    .carbon_count(lapply(c("C2H6O", "H2O", "CH4"), .parse_formula)),
    c(2, 0, 1)
  )
})
