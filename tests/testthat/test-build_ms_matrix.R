mk_ms <- function() {
  list(
    data = cbind(
      rt = c(1, 1, 1, 2, 2, 3),
      mz = c(39.9, 40.4, 41, 40, 60, 41),
      intensity = c(1, 2, 3, 4, 5, 6)
    ),
    rt = c(1, 2, 3)
  )
}

test_that("build_ms_matrix() returns D, rt and mz with matching dimensions", {
  out <- build_ms_matrix(mk_ms(), mz_min = 40, mz_max = 41, mz_bin = 1)
  expect_named(out, c("D", "rt", "mz"))
  expect_equal(dim(out$D), c(3L, 2L))
  expect_equal(out$mz, c(40, 41))
  expect_equal(out$D[1, ], c("40" = 3, "41" = 3))
})

test_that("build_ms_matrix() dense output equals the sparse matrix", {
  out <- build_ms_matrix(mk_ms(), mz_min = 40, mz_max = 41, mz_bin = 1)
  sp <- .build_sparse_ms_matrix(mk_ms(), 40, 41, 1)
  expect_equal(out$D, as.matrix(sp))
})

test_that("build_ms_matrix() subsets scans by rt_range inclusively", {
  out <- build_ms_matrix(
    mk_ms(),
    rt_range = c(2, 3),
    mz_min = 40,
    mz_max = 41,
    mz_bin = 1
  )
  expect_equal(out$rt, c(2, 3))
  expect_equal(nrow(out$D), 2L)
})

test_that("build_ms_matrix() uses option defaults", {
  withr::local_options(moosaic.mz_min = 40, moosaic.mz_max = 41)
  expect_equal(build_ms_matrix(mk_ms())$mz, c(40, 41))
})

test_that("build_ms_matrix() accepts a gcms_fid_exp", {
  e <- structure(list(ms = mk_ms()), class = "gcms_fid_exp")
  out <- build_ms_matrix(e, mz_min = 40, mz_max = 41, mz_bin = 1)
  expect_equal(nrow(out$D), 3L)
})
