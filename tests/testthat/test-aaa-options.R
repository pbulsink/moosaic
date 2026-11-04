test_that(".moosaic_default_options() returns a named list with all expected keys", {
  opts <- .moosaic_default_options()
  expect_type(opts, "list")
  expect_named(opts)

  # Check a sample of keys exist
  expected_keys <- c(
    "moosaic.library_path",
    "moosaic.search_function",
    "moosaic.rank_max",
    "moosaic.als_thresh"
  )
  expect_true(all(expected_keys %in% names(opts)))
})

test_that(".onLoad sets unset options but preserves pre-set values", {
  # Pre-set a custom value
  withr::local_options(moosaic.rank_max = 12L)
  # Simulate .onLoad
  .onLoad("moosaic", "moosaic")
  # Pre-set value should be preserved
  expect_equal(getOption("moosaic.rank_max"), 12L)
  # An unset option should now be set from defaults
  expect_equal(getOption("moosaic.als_thresh"), 0.001)
})

test_that("moosaic_options() returns only moosaic.* options", {
  withr::local_options(moosaic.rank_max = 8L, foo.bar = 1)
  opts <- moosaic_options()
  expect_true(all(startsWith(names(opts), "moosaic.")))
})

test_that("set_moosaic_options() sets named options and returns old values", {
  withr::local_options(moosaic.rank_max = 6L)
  old <- set_moosaic_options(rank_max = 10L, search_hits = 20L)
  expect_equal(getOption("moosaic.rank_max"), 10L)
  expect_equal(getOption("moosaic.search_hits"), 20L)
  expect_equal(old$moosaic.rank_max, 6L)
})

test_that("set_moosaic_options() aborts on unknown option", {
  expect_error(
    set_moosaic_options(unknown_option = 1),
    class = "moosaic-error-unknown_option"
  )
})

test_that("set_moosaic_options() with no args returns invisible list", {
  result <- set_moosaic_options()
  expect_type(result, "list")
})

test_that("reset_moosaic_options() restores all defaults", {
  withr::local_options(moosaic.rank_max = 12L, moosaic.als_thresh = 0.1)
  reset_moosaic_options()
  expect_equal(getOption("moosaic.rank_max"), 6L)
  expect_equal(getOption("moosaic.als_thresh"), 0.001)
})

test_that(".get_moosaic_option() reads a valid option", {
  withr::local_options(moosaic.rank_max = 8L)
  val <- .get_moosaic_option("rank_max")
  expect_equal(val, 8L)
})

test_that(".get_moosaic_option() aborts on unknown option", {
  expect_error(
    .get_moosaic_option("unknown_thing"),
    class = "moosaic-error-unknown_option"
  )
})

test_that(".moosaic_abort() produces moosaic-error class", {
  expect_error(
    .moosaic_abort("test error", "test_class"),
    class = "moosaic-error-test_class"
  )
})

test_that("specify_library() accepts character vector and stores as list", {
  # Create temp dirs
  dir1 <- withr::local_tempdir()
  dir2 <- withr::local_tempdir()
  specify_library(c(dir1, dir2))
  lib <- getOption("moosaic.library_path")
  expect_type(lib, "list")
  expect_length(lib, 2)
})

test_that("specify_library() accepts list input", {
  dir1 <- withr::local_tempdir()
  specify_library(list(dir1))
  lib <- getOption("moosaic.library_path")
  expect_type(lib, "list")
})

test_that("specify_library() aborts on missing path", {
  expect_error(
    specify_library("/nonexistent/path"),
    class = "moosaic-error-missing_path"
  )
})

test_that("specify_ri_calibration() aborts on missing file", {
  expect_error(
    specify_ri_calibration("/nonexistent/ONSITE.CAL"),
    class = "moosaic-error-missing_file"
  )
})

test_that("specify_search_params() validates type via arg_match", {
  expect_error(
    specify_search_params(type = "bad_type"),
    "must be one of"
  )
})

test_that("specify_search_params() validates hits as positive integer", {
  expect_error(
    specify_search_params(hits = -1),
    class = "moosaic-error-bad_input"
  )
})

test_that("specify_search_params() sets valid parameters", {
  specify_search_params(type = "hybrid", hits = 15L, threads = 2L)
  expect_equal(getOption("moosaic.search_function"), "hybrid")
  expect_equal(getOption("moosaic.search_hits"), 15L)
  expect_equal(getOption("moosaic.search_threads"), 2L)
})

test_that("specify_identification_penalties() sets penalties", {
  specify_identification_penalties(
    ri_grace = 15,
    element_penalties = c(N = 60, S = 60)
  )
  expect_equal(getOption("moosaic.ri_grace"), 15)
  expect_equal(getOption("moosaic.element_penalties")["N"], c(N = 60))
})
