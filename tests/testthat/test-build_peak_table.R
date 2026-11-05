test_that(".build_peak_table() builds one row per analyte component ordered by rt", {
  res <- mk_qresult(
    rt = c(9, 3),
    area = c(20, 10),
    name = c("Toluene", NA),
    formula = c("C7H8", NA),
    score = 850,
    ri = c(760, 600)
  )
  bg <- mk_comp("bg", 5, c(`50` = 1))
  bg$is_background <- TRUE
  res$components <- c(res$components, list(bg))
  out <- .build_peak_table(res)
  expect_s3_class(out, "tbl_df")
  expect_equal(nrow(out), 2L)
  expect_equal(out$rt, c(3, 9))
  expect_equal(out$area, c(10, 20))
  expect_equal(out$identified, c(FALSE, TRUE))
  expect_equal(out$name, c(NA, "Toluene"))
  expect_equal(out$score, c(NA, 850))
  expect_equal(out$final_score, c(NA, 845))
  expect_equal(out$ri_delta, c(NA, -1))
  expect_equal(out$mw[2], 7 * 12.011 + 8 * 1.008)
  expect_equal(out$C, c(NA, 7))
  expect_equal(out$N, c(NA, 0))
})

test_that(".build_peak_table() treats unannotated components as unidentified", {
  cmp <- mk_comp("c1", 4, c(`50` = 1))
  res <- structure(
    list(components = list(cmp), identifications = tibble::tibble()),
    class = "moosaic_result"
  )
  out <- .build_peak_table(res)
  expect_false(out$identified)
  expect_true(is.na(out$ri))
})

test_that(".build_peak_table() returns zero rows without analyte components", {
  res <- structure(
    list(components = list(), identifications = tibble::tibble()),
    class = "moosaic_result"
  )
  expect_equal(nrow(.build_peak_table(res)), 0L)
})

test_that(".build_peak_table() falls back to the library mass for unsupported elements", {
  res <- mk_qresult(4, 10, "Sodium acetate", "C2H3NaO2", ri = 500)
  res$components[[1]]$hits$mw <- 82
  out <- .build_peak_table(res)
  expect_equal(out$mw, 82)
  expect_equal(out$C, 2)
})
