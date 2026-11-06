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
