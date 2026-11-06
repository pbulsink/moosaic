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

test_that("identify_components() annotates analytes in one search and skips background", {
  c1 <- mk_comp("w1_c1", 2, c(`78` = 1))
  c2 <- mk_comp("w1_c2", 8, c(`94` = 1))
  bg <- mk_comp("w1_c3", 5, c(`73` = 1))
  bg$is_background <- TRUE
  res <- structure(
    list(
      components = list(c1, c2, bg),
      windows = tibble::tibble(window_id = 1L)
    ),
    class = "moosaic_result"
  )
  calls <- 0L
  tbl <- list(
    w1_c1 = mk_hits(
      c("Benzene", "Odd"),
      c(900, 920),
      c("C6H6", "C6H6"),
      c(650, 900)
    ),
    w1_c2 = mk_hits("Phenol", 880, "C6H6O", 940)
  )
  inner <- mock_search(tbl)
  local_mocked_bindings(.run_mspepsearch = \(q) {
    calls <<- calls + 1L
    expect_equal(vapply(q, \(x) x$name, ""), c("w1_c1", "w1_c2"))
    inner(q)
  })
  withr::local_options(moosaic.min_match_factor = 600)
  out <- identify_components(res, ri_cal = cal)
  expect_equal(calls, 1L)
  expect_s3_class(out, "moosaic_result")
  expect_equal(
    vapply(out$components, \(x) x$name %||% NA_character_, ""),
    c("Benzene", "Phenol", NA)
  )
  expect_named(
    out$identifications,
    c(
      "component_id",
      "hit_rank",
      "name",
      "cas",
      "formula",
      "mw",
      "mf",
      "rmf",
      "prob",
      "library_ri",
      "observed_ri",
      "ri_penalty",
      "ri_missing",
      "element_penalty",
      "final",
      "final_rank"
    )
  )
})

test_that("identify_components() reads the calibration from the option when not given", {
  f <- withr::local_tempfile(
    lines = c("1 600 1 1 A", "5 800 1 1 B", "10 1000 1 1 C")
  )
  withr::local_options(moosaic.ri_calibration_path = f)
  res <- structure(
    list(components = list(mk_comp("w1_c1", 5, c(`78` = 1))), windows = NULL),
    class = "moosaic_result"
  )
  local_mocked_bindings(
    .run_mspepsearch = mock_search(list(
      w1_c1 = mk_hits("Benzene", 900, "C6H6", 800)
    ))
  )
  out <- identify_components(res)
  expect_equal(out$components[[1]]$ri, 800)
})

test_that("identify_components() rejects a bad result", {
  expect_error(
    identify_components(list()),
    class = "moosaic-error-bad_argument"
  )
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
