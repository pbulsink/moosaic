test_that(".recovery_excluded() lists solvent names, adding methanol on request", {
  expect_true("Methylene chloride" %in% .recovery_excluded())
  expect_false("Methanol" %in% .recovery_excluded())
  expect_true(all(
    c("Methanol", "Methyl Alcohol") %in% .recovery_excluded(TRUE)
  ))
})
