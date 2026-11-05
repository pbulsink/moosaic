test_that(".apply_curve() evaluates the polynomial per row", {
  curve <- tibble::tibble(
    intercept = c(0, 1),
    slope = c(2, 2),
    quad = c(0, 0.5)
  )
  expect_equal(.apply_curve(c(3, 2), curve), c(6, 1 + 4 + 2))
})

test_that(".apply_curve() clips negative amounts to zero", {
  curve <- tibble::tibble(intercept = -10, slope = 1, quad = 0)
  expect_equal(.apply_curve(2, curve), 0)
})
