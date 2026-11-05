test_that(".element_counts() returns one row of tracked-element counts per formula", {
  out <- .element_counts(c("C6H6", "C5H5N", NA))
  expect_s3_class(out, "tbl_df")
  expect_equal(names(out), .tracked_elements)
  expect_equal(out$C, c(6, 5, NA))
  expect_equal(out$N, c(0, 1, NA))
  expect_equal(out$Cl, c(0, 0, NA))
})

test_that(".element_counts() handles an empty input", {
  expect_equal(nrow(.element_counts(character())), 0L)
})
