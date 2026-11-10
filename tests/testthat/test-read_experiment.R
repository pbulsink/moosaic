fx <- \(f) test_path("fixtures", "real_run", f)

test_that("read_experiment() aborts when the MS file is missing", {
  expect_error(
    read_experiment("no_such.ms", fx("FID1A.ch")),
    class = "moosaic-error-file_not_found"
  )
})

test_that("read_experiment() aborts when the FID file is missing", {
  skip_if_not(file.exists(fx("data.ms")))
  expect_error(
    read_experiment(fx("data.ms"), "no_such.ch"),
    class = "moosaic-error-file_not_found"
  )
})

test_that("read_experiment() builds a valid gcms_fid_exp from ChemStation files", {
  skip_on_cran()
  skip_if_not(file.exists(fx("data.ms")) && file.exists(fx("FID1A.ch")))
  exp <- read_experiment(fx("data.ms"), fx("FID1A.ch"))
  expect_s3_class(exp, "gcms_fid_exp")
  expect_named(exp, c("ms", "fid", "alignment", "processing"))
  expect_equal(exp$ms$metadata$source_file, fx("data.ms"))
  expect_equal(exp$fid$metadata$source_file, fx("FID1A.ch"))
  expect_equal(exp$alignment$delay, 0)
  expect_false(exp$alignment$validated)
  expect_equal(
    exp$processing$read_experiment,
    list(ms_file = fx("data.ms"), fid_file = fx("FID1A.ch"))
  )
  expect_length(exp$ms$tic, length(exp$ms$rt))
  expect_false(is.unsorted(exp$ms$rt))
  expect_length(exp$fid$intensity, length(exp$fid$rt))
})
