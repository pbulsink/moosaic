gauss <- function(rt, c, w, h = 100) h * exp(-0.5 * ((rt - c) / w)^2)
rt <- seq(0, 4, by = 1 / 3000)

test_that(".has_shoulder() is FALSE for a single Gaussian", {
  y <- gauss(rt, 2, 0.03)
  a <- which.max(y)
  expect_false(.has_shoulder(y, rt, a, a - 300, a + 300))
})

test_that(".has_shoulder() is TRUE for a fused doublet", {
  y <- gauss(rt, 2, 0.03) + gauss(rt, 2.06, 0.03, 60)
  a <- which.max(y)
  expect_true(.has_shoulder(y, rt, a, a - 300, a + 400))
})

test_that(".has_shoulder() is FALSE for peaks too narrow to evaluate", {
  y <- gauss(rt, 2, 0.03)
  a <- which.max(y)
  expect_false(.has_shoulder(y, rt, a, a - 10, a + 10))
})

test_that(".has_shoulder() is FALSE when the context is shorter than the filter", {
  expect_false(.has_shoulder(c(0, 1, 3, 1, 0), 1:5, 3L, 1L, 5L, width_frac = 5))
})
