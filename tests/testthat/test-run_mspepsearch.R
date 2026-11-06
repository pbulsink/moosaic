test_that(".run_mspepsearch() aborts without a library", {
  withr::local_options(moosaic.library_path = NULL)
  expect_error(
    .run_mspepsearch(list(list(name = "a", mz = 41, intst = 999L))),
    class = "moosaic-error-missing_library"
  )
})

test_that(".run_mspepsearch() dispatches on the search function option and passes results through", {
  lib <- withr::local_tempdir()
  withr::local_options(
    moosaic.library_path = list(lib),
    moosaic.search_function = "hybrid",
    moosaic.search_hits = 7L,
    moosaic.search_threads = 2L
  )
  seen <- NULL
  fake <- function(spectra, libraries, ...) {
    seen <<- list(spectra = spectra, libraries = libraries, args = list(...))
    "sentinel"
  }
  local_mocked_bindings(.search_fn = \(type) {
    seen_type <<- type
    fake
  })
  seen_type <- NULL
  q <- list(
    list(name = "a", mz = 41, intst = 999L),
    list(name = "b", mz = 42, intst = 999L)
  )
  expect_equal(.run_mspepsearch(q), "sentinel")
  expect_equal(seen_type, "hybrid")
  expect_equal(seen$spectra, q)
  expect_equal(seen$libraries, lib)
  expect_equal(seen$args$n_hits, 7L)
  expect_equal(seen$args$n_threads, 2L)
})

test_that(".search_fn() maps option values to mspepsearchr functions and rejects unknown types", {
  skip_if_not_installed("mspepsearchr")
  expect_identical(.search_fn("identity"), mspepsearchr::IdentitySearchEiNormal)
  expect_identical(.search_fn("simple"), mspepsearchr::SimilaritySearchEiSimple)
  expect_error(.search_fn("bogus"), class = "moosaic-error-bad_argument")
})

hit_df <- function(name, mf, unk, ri = NA_real_, formula = "C6H6") {
  df <- data.frame(
    name = name,
    mf = mf,
    rmf = mf,
    prob = 50,
    formula = formula,
    mw = 78,
    inchikey = "X",
    cas = "71-43-2",
    ri = ri
  )
  attr(df, "unknown_name") <- unk
  df
}

test_that(".parse_search_results() stacks hits into a tibble keyed by component", {
  hits <- list(
    rbind(
      hit_df("Benzene", 900, "c1"),
      hit_df("Toluene", 800, "c1", formula = "C7H8")
    ) |>
      (\(d) structure(d, unknown_name = "c1"))(),
    hit_df("Phenol", 850, "c2", ri = 980, formula = "C6H6O")
  )
  out <- .parse_search_results(hits)
  expect_s3_class(out, "tbl_df")
  expect_named(
    out,
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
      "library_ri"
    )
  )
  expect_equal(out$component_id, c("c1", "c1", "c2"))
  expect_equal(out$hit_rank, c(1L, 2L, 1L))
  expect_equal(out$library_ri, c(NA, NA, 980))
})

test_that(".parse_search_results() returns a zero-row tibble for no hits", {
  for (h in list(list(), list(hit_df("a", 1, "c1")[0, ]))) {
    out <- .parse_search_results(h)
    expect_equal(nrow(out), 0L)
    expect_true("component_id" %in% names(out))
  }
})

test_that(".run_mspepsearch() never asks for more threads than queries", {
  seen <- NULL
  withr::local_options(
    moosaic.library_path = list(tempdir()),
    moosaic.search_threads = 4L
  )
  local_mocked_bindings(
    .search_fn = \(type, ...) {
      \(spectra, libraries, n_hits, n_threads, ri_column_type) {
        seen <<- n_threads
        list()
      }
    }
  )
  .run_mspepsearch(list(list(name = "a")))
  expect_equal(seen, 1L)
})
