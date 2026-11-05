test_that(".build_tic() equals the per-scan intensity sum", {
  ms <- list(
    data = cbind(
      rt = c(1, 1, 2, 3, 3, 3),
      mz = c(40, 41, 40, 40, 41, 42),
      intensity = c(1, 2, 4, 5, 6, 7)
    ),
    rt = c(1, 2, 3)
  )
  expect_equal(.build_tic(ms), c(3, 4, 18))
})

test_that(".build_tic() gives zero for scans without ions", {
  ms <- list(
    data = cbind(rt = 1, mz = 40, intensity = 5),
    rt = c(1, 2)
  )
  expect_equal(.build_tic(ms), c(5, 0))
})
