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

test_that(".component_to_query() aborts for an empty spectrum", {
  cmp <- mk_comp("w1_c1", 5, c(`40` = 0, `41` = 0))
  expect_error(
    .component_to_query(cmp, NA),
    class = "moosaic-error-bad_argument"
  )
})

test_that("write_msp() writes one MSP block per component", {
  comps <- list(
    mk_comp("w1_c1", 5, c(`40` = 0, `41` = 2, `42` = 1)),
    mk_comp("w1_c2", 6, c(`50` = 1, `51` = 3))
  )
  comps[[2]]$ri <- 812.4
  f <- withr::local_tempfile(fileext = ".msp")
  expect_equal(write_msp(comps, f), f, ignore_attr = TRUE)
  expect_snapshot(writeLines(readLines(f)))
})

test_that("write_msp() accepts a moosaic_result and skips background components", {
  bg <- mk_comp("w1_c3", 5, c(`73` = 1, `207` = 1))
  bg$is_background <- TRUE
  res <- structure(
    list(components = list(mk_comp("w1_c1", 5, c(`41` = 1, `42` = 2)), bg)),
    class = "moosaic_result"
  )
  f <- withr::local_tempfile(fileext = ".msp")
  write_msp(res, f)
  expect_equal(sum(grepl("^NAME:", readLines(f))), 1L)
})
