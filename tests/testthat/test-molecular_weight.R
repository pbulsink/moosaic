test_that(".molecular_weight() sums atomic weights over atom counts", {
  expect_equal(
    .molecular_weight(.parse_formula("C6H6")),
    6 * 12.011 + 6 * 1.008
  )
  expect_equal(.molecular_weight(.parse_formula("CH4")), 12.011 + 4 * 1.008)
})

test_that(".molecular_weight() is vectorised over a list of counts", {
  out <- .molecular_weight(lapply(c("CH4", "H2O"), .parse_formula))
  expect_equal(out, c(12.011 + 4 * 1.008, 2 * 1.008 + 15.999))
  expect_equal(.molecular_weight(list()), numeric(0))
})

test_that(".molecular_weight() aborts on an element without an atomic weight", {
  expect_error(
    .molecular_weight(c(C = 1L, Na = 1L)),
    class = "moosaic-error-bad_formula"
  )
})
