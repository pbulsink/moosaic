test_that(".summary_notes() and .element_note() return report text", {
  expect_type(.summary_notes(), "character")
  expect_length(.summary_notes(), 5L)
  expect_match(.element_note(), "does not include H2O")
})
