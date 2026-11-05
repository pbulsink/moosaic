test_that(".integrate_trapezoid() is exact for a linear function and handles uneven spacing", {
  x <- c(0, 1, 3, 4)
  expect_equal(.integrate_trapezoid(x, 2 * x), 16)
  expect_equal(
    .integrate_trapezoid(
      seq(0, pi, length.out = 2001),
      sin(seq(0, pi, length.out = 2001))
    ),
    2,
    tolerance = 1e-6
  )
})

test_that(".integrate_trapezoid() returns 0 for fewer than two points and aborts on mismatch", {
  expect_equal(.integrate_trapezoid(1, 5), 0)
  expect_error(
    .integrate_trapezoid(1:3, 1:2),
    class = "moosaic-error-bad_argument"
  )
})

test_that(".integrate_trapezoid() ignores missing pairs", {
  expect_equal(.integrate_trapezoid(c(0, 1, 2, 3), c(1, NA, 1, 1)), 3)
})
