test_that(".correct_baseline() removes a linear drift", {
  x <- 5 + 0.02 * seq_len(400)
  # Edges (within a window) are biased by padding
  expect_equal(
    .correct_baseline(x, window = 41)[50:350],
    rep(0, 301),
    tolerance = 1e-8
  )
})

test_that(".correct_baseline() leaves a flat zero signal unchanged", {
  expect_equal(.correct_baseline(rep(0, 200)), rep(0, 200))
})

test_that(".correct_baseline() keeps a narrow peak on a drifting baseline", {
  i <- seq_len(600)
  x <- 3 + 0.01 * i + 50 * exp(-0.5 * ((i - 300) / 4)^2)
  out <- .correct_baseline(x, window = 61)
  expect_equal(max(out), 50, tolerance = 0.05)
  expect_lt(abs(out[100]), 0.5)
})

test_that(".correct_baseline() with method none returns x and bad methods abort", {
  expect_equal(.correct_baseline(1:5, "none"), 1:5)
  expect_error(.correct_baseline(1:5, "bogus"))
})

test_that(".correct_baseline() adjusts even and oversized windows", {
  expect_length(.correct_baseline(rep(1, 30), window = 10), 30)
  expect_length(.correct_baseline(rep(1, 30), window = 500), 30)
})
