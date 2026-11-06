test_that(".derivative_signal() recovers first and second derivatives of a quadratic", {
  rt <- seq(0, 10, by = 0.1)
  y <- 2 * rt^2
  expect_equal(.derivative_signal(y, rt, 1)[10:90], 4 * rt[10:90])
  expect_equal(.derivative_signal(y, rt, 2)[10:90], rep(4, 81))
})

test_that(".derivative_signal() aborts on length mismatch and short input", {
  expect_error(
    .derivative_signal(1:10, 1:9),
    class = "moosaic-error-bad_argument"
  )
  expect_error(.derivative_signal(1:3, 1:3), class = "moosaic-error-bad_window")
})
