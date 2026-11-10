test_that(".from_als_output() reshapes a hand-built als() result", {
  C <- matrix(1, 4, 2)
  S <- matrix(2, 3, 2)
  fake <- list(
    CList = list(C),
    S = S,
    rss = 0.5,
    resid = list(matrix(0.1, 4, 3)),
    iter = 7
  )
  out <- .from_als_output(
    fake,
    rt = c(1, 2, 3, 4),
    mz = c(40, 41, 42),
    maxiter = 10
  )
  expect_equal(dim(out$concentration), c(4L, 2L))
  expect_equal(dim(out$spectra), c(3L, 2L))
  expect_equal(dim(out$residuals), c(4L, 3L))
  expect_equal(rownames(out$concentration), as.character(c(1, 2, 3, 4)))
  expect_equal(rownames(out$spectra), c("40", "41", "42"))
  expect_equal(out$iter, 7)
  expect_true(out$converged)
  expect_false(.from_als_output(fake, 1:4, 1:3, maxiter = 7)$converged)
})

test_that(".from_als_output() records a negative final RD from the trace", {
  fake <- list(
    CList = list(matrix(1, 4, 2)),
    S = matrix(1, 3, 2),
    rss = 1.1,
    resid = list(matrix(0, 4, 3)),
    iter = 2,
    trace = c(
      "Initial RSS 3 ",
      "Iteration (opt. S): 1, RSS: 1, RD: 0.5",
      "Iteration (opt. C): 2, RSS: 1.1, RD: -0.1"
    )
  )
  out <- .from_als_output(fake, 1:4, 1:3, maxiter = 10)
  expect_equal(out$rd, c(0.5, -0.1))
  expect_lt(out$rd_final, 0)
})
