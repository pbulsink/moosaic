test_that(".run_als() recovers a noiseless rank-2 problem with non-negative factors", {
  d <- als_fixture(2)
  inp <- .to_als_input(d$D, d$C0, d$S0, seq_len(40), seq_len(30) + 34)
  fit <- .run_als(
    inp,
    maxiter = 100,
    thresh = 0.3,
    unimodal = TRUE,
    baseline = FALSE
  )
  expect_lt(fit$rss / sum(d$D^2), 1e-4)
  expect_true(all(fit$CList[[1]] >= 0))
  expect_true(all(fit$S >= 0))
  expect_type(fit$trace, "character")
  expect_gt(length(fit$trace), 0L)
})

test_that(".run_als() prints nothing to the console", {
  d <- als_fixture(2)
  inp <- .to_als_input(d$D, d$C0, d$S0, seq_len(40), seq_len(30) + 34)
  expect_silent(
    .run_als(
      inp,
      maxiter = 20,
      thresh = 0.3,
      unimodal = TRUE,
      baseline = FALSE
    )
  )
})

test_that(".run_als() warns but returns a result when not converged", {
  d <- als_fixture(2)
  inp <- .to_als_input(d$D, d$C0, d$S0, seq_len(40), seq_len(30) + 34)
  expect_warning(
    fit <- .run_als(
      inp,
      maxiter = 1,
      thresh = 1e-9,
      unimodal = TRUE,
      baseline = FALSE
    ),
    class = "moosaic-warning-als_not_converged"
  )
  expect_false(is.null(fit$S))
})

test_that("a flat background column stays flat and last with baseline = TRUE", {
  d <- als_fixture(2)
  bgD <- d$D + 5
  C0 <- cbind(d$C0, 1)
  S0 <- .build_s0(bgD, 3)
  inp <- .to_als_input(bgD, C0, S0, seq_len(40), seq_len(30) + 34)
  fit <- .run_als(
    inp,
    maxiter = 50,
    thresh = 0.3,
    unimodal = TRUE,
    baseline = TRUE
  )
  bg <- fit$CList[[1]][, 3]
  expect_lt(diff(range(bg)) / max(bg), 0.05)
})
