test_that(".is_solvent() matches solvent names ignoring case and punctuation", {
  expect_equal(
    .is_solvent(c(
      "Methylene chloride",
      "carbon-disulfide",
      "ACETONE",
      "Phenol",
      NA
    )),
    c(TRUE, TRUE, TRUE, FALSE, FALSE)
  )
})
