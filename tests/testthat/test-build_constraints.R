test_that("build_constraints() returns C0 with one column per component", {
  fid <- make_lowrank(2)$fid
  out <- build_constraints(fid, 2)
  expect_named(out, c("C0", "segments", "background_col"))
  expect_equal(dim(out$C0), c(40L, 2L))
  expect_true(is.na(out$background_col))
  expect_equal(nrow(out$segments), 2L)
})

test_that("C0 columns are non-negative, max 1 and zero outside their segment", {
  fid <- make_lowrank(2)$fid
  out <- build_constraints(fid, 2)
  expect_true(all(out$C0 >= 0))
  expect_equal(apply(out$C0, 2, max), c(1, 1))
  seg <- out$segments
  for (k in 1:2) {
    outside <- setdiff(seq_len(40), seg$start[k]:seg$end[k])
    expect_true(all(out$C0[outside, k] == 0))
  }
})

test_that("C0 columns are measured FID sub-profiles", {
  fid <- make_lowrank(2)$fid
  out <- build_constraints(fid, 2)
  seg <- out$segments
  idx <- seg$start[1]:seg$end[1]
  expect_equal(
    out$C0[idx, 1],
    fid$intensity[idx] / max(fid$intensity[idx])
  )
})

test_that("negative FID values are clipped to zero", {
  fid <- list(
    rt = seq_len(9) * 0.01,
    intensity = c(-1, 2, 5, 2, 1, 3, 6, 3, -2)
  )
  expect_true(all(build_constraints(fid, 2)$C0 >= 0))
})

test_that("background = TRUE appends a flat last column", {
  fid <- make_lowrank(2)$fid
  out <- build_constraints(fid, 2, background = TRUE)
  expect_equal(dim(out$C0), c(40L, 3L))
  expect_equal(out$background_col, 3L)
  expect_equal(out$C0[, 3], rep(1, 40))
})

test_that("rank above the number of peaks splits a segment and informs", {
  fid <- make_lowrank(1)$fid
  expect_message(out <- build_constraints(fid, 2), class = "moosaic-message")
  expect_equal(ncol(out$C0), 2L)
})

test_that("build_constraints() validates input", {
  fid <- make_lowrank(1)$fid
  expect_error(build_constraints(fid, 0), class = "moosaic-error-bad_argument")
  expect_error(
    build_constraints(fid, 1, background = "x"),
    class = "moosaic-error-bad_argument"
  )
})
