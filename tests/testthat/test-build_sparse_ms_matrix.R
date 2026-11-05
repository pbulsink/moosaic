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

test_that(".build_sparse_ms_matrix() sums ions sharing a nominal bin", {
  m <- .build_sparse_ms_matrix(mk_ms(), 40, 41, 1)
  expect_s4_class(m, "dgCMatrix")
  expect_equal(as.matrix(m)[1, ], c("40" = 3, "41" = 3))
})

test_that(".build_sparse_ms_matrix() has expected dims and drops out-of-range ions", {
  m <- .build_sparse_ms_matrix(mk_ms(), 40, 41, 1)
  expect_equal(dim(m), c(3L, 2L))
  expect_equal(colnames(m), c("40", "41"))
  expect_equal(sum(m), 1 + 2 + 3 + 4 + 6)
})

test_that(".build_sparse_ms_matrix() aborts on bad inputs", {
  expect_error(
    .build_sparse_ms_matrix(mk_ms(), 50, 40, 1),
    class = "moosaic-error-bad_argument"
  )
  ms <- mk_ms()
  colnames(ms$data) <- c("a", "b", "c")
  expect_error(
    .build_sparse_ms_matrix(ms, 40, 41, 1),
    class = "moosaic-error-bad_format"
  )
})
