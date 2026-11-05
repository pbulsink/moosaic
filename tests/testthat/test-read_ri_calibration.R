cal_lines <- c(
  "1.0 100.0 100 100 A",
  "2.0 200.0 100 100 1-methyl naphthalene",
  "4.0 250.0 100 100 Toluene",
  ""
)

test_that("read_ri_calibration() parses columns, types and multi-word names", {
  f <- withr::local_tempfile(lines = cal_lines)
  cal <- read_ri_calibration(f)
  expect_s3_class(cal, "tbl_df")
  expect_named(cal, c("rt", "ri", "col3", "col4", "name"))
  expect_equal(nrow(cal), 3L)
  expect_type(cal$rt, "double")
  expect_type(cal$name, "character")
  expect_equal(cal$name, c("A", "1-methyl naphthalene", "Toluene"))
  expect_equal(cal$ri, c(100, 200, 250))
})

test_that("read_ri_calibration() ignores trailing blank lines", {
  f <- withr::local_tempfile(lines = c(cal_lines, "", "  "))
  expect_equal(nrow(read_ri_calibration(f)), 3L)
})

test_that("read_ri_calibration() aborts on a missing file", {
  expect_error(
    read_ri_calibration(file.path(tempdir(), "nope.cal")),
    class = "moosaic-error-missing_file"
  )
})

test_that("read_ri_calibration() aborts on too few rows or non-increasing values", {
  expect_error(
    read_ri_calibration(withr::local_tempfile(lines = "1 100 1 1 A")),
    class = "moosaic-error-bad_calibration"
  )
  expect_error(
    read_ri_calibration(withr::local_tempfile(
      lines = c("2 100 1 1 A", "1 200 1 1 B")
    )),
    class = "moosaic-error-bad_calibration"
  )
  expect_error(
    read_ri_calibration(withr::local_tempfile(
      lines = c("1 200 1 1 A", "2 100 1 1 B")
    )),
    class = "moosaic-error-bad_calibration"
  )
})

test_that("read_ri_calibration() names the line of a non-numeric field", {
  f <- withr::local_tempfile(
    lines = c("1 100 1 1 A", "2 abc 1 1 B", "3 300 1 1 C")
  )
  expect_error(
    read_ri_calibration(f),
    regexp = "line 2",
    class = "moosaic-error-bad_calibration"
  )
})

test_that("read_ri_calibration() parses the ONSITE.CAL fixture", {
  expect_no_error(read_ri_calibration(test_path(
    "fixtures",
    "ri",
    "ONSITE.CAL"
  )))
})
