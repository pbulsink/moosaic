test_that(".bin_mz() maps fractional m/z to the nearest nominal bin", {
  expect_equal(.bin_mz(c(39.9, 40.4), mz_min = 40, mz_bin = 1), c(1L, 1L))
})

test_that(".bin_mz() supports non-unit bin widths", {
  expect_equal(
    .bin_mz(c(40, 40.5, 41), mz_min = 40, mz_bin = 0.5),
    c(1L, 2L, 3L)
  )
})

test_that(".bin_mz() returns indices outside 1..n for out-of-range m/z", {
  expect_equal(.bin_mz(c(35, 50), mz_min = 40, mz_bin = 1), c(-4L, 11L))
})

test_that(".bin_mz() aborts on a bad bin width", {
  expect_error(.bin_mz(40, 40, 0), class = "moosaic-error-bad_argument")
})
