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
