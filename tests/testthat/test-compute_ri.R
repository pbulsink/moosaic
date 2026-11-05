ref <- tibble::tibble(
  rt = c(1, 2, 4, 5),
  ri = c(100, 250, 310, 500)
)

test_that(".compute_ri() returns the reference RI at a reference rt and interpolates", {
  expect_equal(.compute_ri(c(1, 4, 5), ref), c(100, 310, 500))
  expect_equal(.compute_ri(1.5, ref), 175)
  expect_equal(.compute_ri(3, ref), 280)
})

test_that(".compute_ri() gives NA with a warning outside the range", {
  expect_warning(
    out <- .compute_ri(c(0.5, 3, 6), ref),
    class = "moosaic-warning-ri_out_of_range"
  )
  expect_equal(out, c(NA, 280, NA))
})

test_that(".compute_ri() extrapolates linearly when ri_extrapolate is TRUE", {
  withr::local_options(moosaic.ri_extrapolate = TRUE)
  expect_equal(.compute_ri(0, ref), 100 - 150)
  expect_equal(.compute_ri(6, ref), 500 + 190)
})

test_that(".compute_ri() keeps NA input as NA and needs at least two references", {
  expect_equal(.compute_ri(NA_real_, ref), NA_real_)
  expect_error(
    .compute_ri(1, ref[1, ]),
    class = "moosaic-error-bad_calibration"
  )
})
