test_that(".to_als_input() matches the als() signature", {
  d <- als_fixture()
  rt <- seq_len(40) * 0.0045
  mz <- seq_len(30) + 34
  inp <- .to_als_input(d$D, d$C0, d$S0, rt, mz)
  expect_named(inp, c("CList", "PsiList", "S", "x", "x2"))
  expect_length(inp$CList, 1L)
  expect_length(inp$PsiList, 1L)
  expect_equal(dim(inp$CList[[1]]), c(40L, 2L))
  expect_equal(dim(inp$PsiList[[1]]), c(40L, 30L))
  expect_equal(dim(inp$S), c(30L, 2L))
  expect_equal(inp$x, rt)
  expect_equal(inp$x2, mz)
  expect_true(all(names(inp) %in% names(formals(ALS::als))))
  expect_no_error(utils::capture.output(do.call(
    ALS::als,
    c(inp, list(maxiter = 2))
  )))
})

test_that(".to_als_input() aborts on dimension mismatches", {
  d <- als_fixture()
  expect_error(
    .to_als_input(d$D, d$C0[-1, ], d$S0, seq_len(40), seq_len(30)),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    .to_als_input(d$D, d$C0, d$S0[-1, ], seq_len(40), seq_len(30)),
    class = "moosaic-error-bad_argument"
  )
  expect_error(
    .to_als_input(d$D, d$C0, d$S0[, 1, drop = FALSE], seq_len(40), seq_len(30)),
    class = "moosaic-error-bad_argument"
  )
})
