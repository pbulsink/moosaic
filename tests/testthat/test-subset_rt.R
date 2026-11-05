test_that(".subset_rt() includes both bounds", {
  D <- matrix(1:8, 4)
  out <- .subset_rt(D, c(1, 2, 3, 4), 2, 3)
  expect_equal(out$rt, c(2, 3))
  expect_equal(out$D, D[2:3, ])
})

test_that(".subset_rt() aborts on an empty window", {
  expect_error(
    .subset_rt(matrix(1:4, 2), c(1, 2), 5, 6),
    class = "moosaic-error-empty_window"
  )
})

test_that(".subset_rt() aborts on reversed bounds", {
  expect_error(
    .subset_rt(matrix(1:4, 2), c(1, 2), 2, 1),
    class = "moosaic-error-bad_window"
  )
})
