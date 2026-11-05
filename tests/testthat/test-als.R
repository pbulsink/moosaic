als_fixture <- function(rank = 2, ...) {
  d <- make_lowrank(rank, ...)
  rownames(d$D) <- NULL
  colnames(d$D) <- as.character(seq_len(ncol(d$D)) + 34)
  d$C0 <- .normalize_columns(d$C + 0.05)
  d$S0 <- .build_s0(d$D, rank)
  d
}

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

test_that(".als_diagnostics() reports fit quality for a perfect fit", {
  d <- als_fixture(2)
  info <- list(iter = 5, converged = TRUE, rd_final = 1e-4)
  dg <- .als_diagnostics(d$D, 100 * d$C, d$S, info)
  expect_equal(dg$lack_of_fit, 0, tolerance = 1e-8)
  expect_equal(dg$r2, 1)
  expect_equal(dg$iter, 5)
  expect_true(dg$converged)
  expect_length(dg$explained_variance, 2L)
  expect_true(all(dg$explained_variance > 0))
})

test_that(".is_background_component() flags bleed ions and flat profiles", {
  mz <- 35:400
  bleed <- setNames(rep(0.01, length(mz)), mz)
  bleed[c("73", "207", "281")] <- 1
  peak <- exp(-0.5 * ((1:40 - 20) / 3)^2)
  expect_true(.is_background_component(peak, bleed))
  analyte <- setNames(rep(0, length(mz)), mz)
  analyte[c("91", "106", "77")] <- c(1, 0.8, 0.3)
  expect_false(.is_background_component(peak, analyte))
  expect_true(.is_background_component(rep(1, 40), analyte))
})

test_that("fit_window() returns concentration, spectra, residuals and diagnostics", {
  d <- als_fixture(2)
  withr::local_options(moosaic.als_thresh = 0.3)
  fit <- fit_window(d$D, 2, d$C0)
  expect_named(fit, c("concentration", "spectra", "residuals", "diagnostics"))
  expect_equal(dim(fit$concentration), c(40L, 2L))
  expect_equal(dim(fit$spectra), c(30L, 2L))
  expect_equal(dim(fit$residuals), dim(d$D))
  expect_lt(fit$diagnostics$lack_of_fit, 5)
})

test_that("fit_window() aborts when rank and C0 disagree", {
  d <- als_fixture(2)
  expect_error(fit_window(d$D, 3, d$C0), class = "moosaic-error-bad_argument")
  expect_error(
    fit_window(d$D, 2, d$C0, background = TRUE),
    class = "moosaic-error-bad_argument"
  )
})

test_that("synthetic overlapping pair is recovered (stage)", {
  d <- als_fixture(2, noise = 0.5, seed = 4417)
  withr::local_options(moosaic.als_thresh = 0.3)
  fit <- fit_window(d$D, 2, d$C0)
  expect_lt(fit$diagnostics$lack_of_fit, 5)
  cosine <- function(a, b) sum(a * b) / sqrt(sum(a^2) * sum(b^2))
  cs <- outer(1:2, 1:2, Vectorize(\(i, j) cosine(fit$spectra[, i], d$S[, j])))
  expect_gt(max(cs[1, ]), 0.98)
  expect_gt(max(cs[2, ]), 0.98)
})
