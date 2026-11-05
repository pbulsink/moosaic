test_that(".apportion_fid_area() shares sum to the raw area", {
  fid <- fid_raw()
  C <- cbind(dnorm(1:40, 15, 4), dnorm(1:40, 25, 4)) + 0.01
  a <- .apportion_fid_area(fid, C)
  expect_length(a, 2L)
  expect_equal(
    sum(a),
    .integrate_trapezoid(fid$rt, fid$intensity),
    tolerance = 1e-8
  )
})

test_that(".apportion_fid_area() splits a scan in proportion to the fitted signal", {
  fid <- list(rt = c(0, 1, 2), intensity = c(4, 4, 4))
  C <- cbind(c(1, 1, 1), c(3, 3, 3))
  expect_equal(.apportion_fid_area(fid, C), c(2, 6))
})

test_that(".apportion_fid_area() excludes background columns", {
  fid <- list(rt = c(0, 1, 2), intensity = c(4, 4, 4))
  C <- cbind(c(1, 1, 1), c(3, 3, 3), c(100, 100, 100))
  a <- .apportion_fid_area(fid, C, is_background = c(FALSE, FALSE, TRUE))
  expect_equal(a, c(2, 6, NA))
  expect_equal(sum(a, na.rm = TRUE), 8)
})

test_that(".apportion_fid_area() aborts when rows differ", {
  expect_error(
    .apportion_fid_area(fid_raw(), matrix(1, 5, 2)),
    class = "moosaic-error-bad_argument"
  )
})
