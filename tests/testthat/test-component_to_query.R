test_that(".component_to_query() scales intensities to an integer maximum of 999 and drops zeros", {
  cmp <- mk_comp("w1_c1", 5, c(`40` = 0, `41` = 2, `42` = 1, `43` = 0.5))
  q <- .component_to_query(cmp, ri = 1234.5)
  expect_named(q, c("name", "mz", "intst", "retention_index"))
  expect_equal(q$name, "w1_c1")
  expect_equal(q$mz, c(41, 42, 43))
  expect_equal(q$intst, c(999L, 500L, 250L))
  expect_type(q$intst, "integer")
  expect_equal(q$retention_index, 1234.5)
})

test_that(".component_to_query() omits the RI when it is NA or NULL", {
  cmp <- mk_comp("w1_c1", 5, c(`40` = 1, `41` = 2))
  expect_false("retention_index" %in% names(.component_to_query(cmp, NA_real_)))
  expect_false("retention_index" %in% names(.component_to_query(cmp, NULL)))
})

test_that(".component_to_query() returns NULL for an empty spectrum", {
  cmp <- mk_comp("w1_c1", 5, c(`40` = 0, `41` = 0))
  expect_null(.component_to_query(cmp, NA))
})

test_that(".component_to_query() returns NULL when every peak is zero or NA", {
  cmp <- mk_comp("w1_c1", 5, c(`40` = 0, `41` = NA, `42` = -1))
  expect_null(.component_to_query(cmp, 800))
})

test_that(".component_to_query() informs when it skips an unsearchable spectrum", {
  cmp <- mk_comp("w1_c1", 5, c(`40` = 0))
  expect_message(
    .component_to_query(cmp, NA),
    class = "moosaic-message-empty_spectrum"
  )
})
