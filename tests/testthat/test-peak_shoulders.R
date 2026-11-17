gauss <- function(rt, c, w, h = 100) h * exp(-0.5 * ((rt - c) / w)^2)
rt <- seq(0, 4, by = 1 / 3000)

test_that(".peak_shoulders() is empty for a single Gaussian", {
  y <- gauss(rt, 2, 0.03)
  a <- which.max(y)
  expect_identical(.peak_shoulders(y, rt, a, a - 300, a + 300), integer())
})

test_that(".peak_shoulders() locates the shoulder of a fused doublet", {
  y <- gauss(rt, 2, 0.03) + gauss(rt, 2.06, 0.03, 60)
  a <- which.max(y)
  sh <- .peak_shoulders(y, rt, a, a - 300, a + 400)
  expect_length(sh, 1L)
  expect_gt(rt[sh], rt[a])
  expect_lt(abs(rt[sh] - 2.06), 0.02)
})

test_that(".peak_shoulders() ignores noise wiggles on a low-SNR peak", {
  set.seed(5307)
  y <- gauss(rt, 2, 0.03, 3) + rnorm(length(rt), sd = 0.2)
  ys <- .smooth_signal(y, 7L)
  a <- which.max(gauss(rt, 2, 0.03))
  expect_gt(length(.peak_shoulders(ys, rt, a, a - 300, a + 300)), 0L)
  expect_identical(
    .peak_shoulders(ys, rt, a, a - 300, a + 300, noise = 0.2),
    integer()
  )
})

test_that(".peak_shoulders() holds dips near the apex to a stricter noise gate", {
  set.seed(5311)
  y <- gauss(rt, 2, 0.03) +
    gauss(rt, 2.09, 0.03, 10) +
    rnorm(length(rt), sd = 0.2)
  ys <- .smooth_signal(y, 7L)
  a <- which.max(ys)
  args <- list(ys, rt, a, a - 300, a + 500, noise = 0.2)
  sh <- do.call(.peak_shoulders, args)
  expect_length(sh, 1L)
  # Flat gate at the apex multiple loses the 3 sigma shoulder
  expect_identical(
    do.call(.peak_shoulders, c(args, list(noise_k = c(40, 40)))),
    integer()
  )
  # A huge flank multiple reached only past 3 sigma also loses it
  expect_identical(
    do.call(.peak_shoulders, c(args, list(noise_k = c(5, 40)))),
    integer()
  )
})

test_that(".peak_shoulders() drops shoulders below min_height", {
  y <- gauss(rt, 2, 0.03) + gauss(rt, 2.06, 0.03, 60)
  a <- which.max(y)
  expect_identical(
    .peak_shoulders(y, rt, a, a - 300, a + 400, min_height = 1e6),
    integer()
  )
})

test_that(".peak_shoulders() is empty for peaks too narrow to evaluate", {
  y <- gauss(rt, 2, 0.03)
  a <- which.max(y)
  expect_identical(.peak_shoulders(y, rt, a, a - 10, a + 10), integer())
})

test_that(".peak_shoulders() is empty when the context is shorter than the filter", {
  expect_identical(
    .peak_shoulders(c(0, 1, 3, 1, 0), 1:5, 3L, 1L, 5L, width_frac = 5),
    integer()
  )
})
