test_that("write_pdf_report() validates its inputs", {
  skip_if_not_installed("quarto")
  expect_error(write_pdf_report(1), class = "moosaic-error-bad_argument")
  expect_error(
    write_pdf_report(mk_quantified(), c("a", "b")),
    class = "moosaic-error-bad_argument"
  )
})

test_that("write_pdf_report() renders the template with the saved result", {
  skip_if_not_installed("quarto")
  rendered <- NULL
  local_mocked_bindings(
    quarto_render = \(input, output_file, execute_params, ...) {
      rendered <<- list(
        input = input,
        out = output_file,
        back = readRDS(execute_params$result_rds)
      )
      file.copy(input, file.path(dirname(input), output_file))
      invisible()
    },
    .package = "quarto"
  )
  path <- withr::local_tempfile(fileext = ".pdf")
  out <- write_pdf_report(mk_quantified(), path)
  expect_equal(out, path)
  expect_true(file.exists(path))
  expect_equal(basename(rendered$input), "report.qmd")
  expect_equal(rendered$out, basename(path))
  expect_equal(rendered$back$quant$info$sample_id, "S1")
})

test_that("write_pdf_report() names the file from the sample by default", {
  skip_if_not_installed("quarto")
  withr::local_dir(withr::local_tempdir())
  local_mocked_bindings(
    quarto_render = \(input, output_file, ...) {
      file.copy(input, file.path(dirname(input), output_file))
      invisible()
    },
    .package = "quarto"
  )
  expect_equal(write_pdf_report(mk_quantified()), "P9_S1_GC-MS-FID.pdf")
})

test_that("write_pdf_report() renders a real PDF when LaTeX is available", {
  skip_if_not_installed("quarto")
  skip_on_cran()
  skip_if(is.null(quarto::quarto_path()), "Quarto is not available")
  skip_if(Sys.which("pdflatex") == "" && Sys.which("xelatex") == "", "No LaTeX")
  path <- withr::local_tempfile(fileext = ".pdf")
  write_pdf_report(mk_quantified(), path)
  expect_true(file.exists(path))
})
