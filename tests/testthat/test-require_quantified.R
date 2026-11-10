test_that(".require_quantified() returns a quantified result invisibly", {
  res <- structure(
    list(peaks = tibble::tibble(), quant = list()),
    class = "moosaic_result"
  )
  expect_invisible(.require_quantified(res))
  expect_identical(.require_quantified(res), res)
})

test_that(".require_quantified() rejects a non-result", {
  expect_error(
    .require_quantified(list(peaks = 1, quant = 1)),
    class = "moosaic-error-bad_argument"
  )
})

test_that(".require_quantified() aborts when quantify() has not been run", {
  res <- structure(list(components = list()), class = "moosaic_result")
  expect_error(.require_quantified(res), class = "moosaic-error-not_quantified")
  res$peaks <- tibble::tibble()
  expect_error(.require_quantified(res), class = "moosaic-error-not_quantified")
})
