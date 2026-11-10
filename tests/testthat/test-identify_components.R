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
