test_that("annotate_component() picks the in-window hit over a higher raw match factor", {
  cmp <- mk_comp("w1_c1", 5, c(`78` = 1, `77` = 0.2))
  local_mocked_bindings(
    .run_mspepsearch = mock_search(list(
      w1_c1 = mk_hits(
        c("far", "near"),
        c(950, 800),
        c("C6H6", "C6H6"),
        c(1200, 802)
      )
    ))
  )
  withr::local_options(
    moosaic.min_match_factor = 600,
    moosaic.ri_penalty_per_unit = 1,
    moosaic.ri_grace = 15
  )
  out <- annotate_component(cmp, ri_cal = cal)
  expect_s3_class(out, "moosaic_component")
  expect_equal(out$ri, 800)
  expect_equal(out$hits$name, c("near", "far"))
  expect_equal(out$name, "near")
  expect_equal(out$hits$ri_penalty[out$hits$name == "far"], 385)
})

test_that("annotate_component() without a calibration scores on MF and elements only", {
  cmp <- mk_comp("w1_c1", 5, c(`78` = 1))
  local_mocked_bindings(
    .run_mspepsearch = mock_search(list(
      w1_c1 = mk_hits(c("a", "b"), c(900, 850), c("C2H3Cl3", "C6H6"), c(NA, NA))
    ))
  )
  out <- annotate_component(cmp)
  expect_true(is.na(out$ri))
  expect_equal(out$name, "b")
})

test_that("annotate_component() drops hits below the minimum match factor", {
  cmp <- mk_comp("w1_c1", 5, c(`78` = 1))
  local_mocked_bindings(
    .run_mspepsearch = mock_search(list(
      w1_c1 = mk_hits(c("a", "b"), c(900, 400), c("C6H6", "C6H6"), c(NA, NA))
    ))
  )
  withr::local_options(moosaic.min_match_factor = 600)
  out <- annotate_component(cmp)
  expect_equal(out$hits$name, "a")
})

test_that("annotate_component() sets name to NA when nothing passes", {
  cmp <- mk_comp("w1_c1", 5, c(`78` = 1))
  local_mocked_bindings(
    .run_mspepsearch = mock_search(list(
      w1_c1 = mk_hits("a", 100, "C6H6", NA)
    ))
  )
  withr::local_options(moosaic.min_match_factor = 600)
  out <- annotate_component(cmp)
  expect_true(is.na(out$name))
  expect_equal(nrow(out$hits), 0L)
})

test_that("annotate_component() rejects a non-component", {
  expect_error(annotate_component(1), class = "moosaic-error-bad_argument")
})

test_that("annotate_component() uses moosaic.disallowed_element_penalty for other elements", {
  cmp <- mk_comp("w1_c1", 5, c(`78` = 1))
  local_mocked_bindings(
    .run_mspepsearch = mock_search(list(
      w1_c1 = mk_hits("fluoro", 900, "CF4", NA)
    ))
  )
  withr::local_options(moosaic.disallowed_element_penalty = 30)
  expect_equal(annotate_component(cmp)$hits$final, 900 - 4 * 30)
})
