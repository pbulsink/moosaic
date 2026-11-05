test_that(".consensus_rank() returns the modal vote and its share", {
  out <- .consensus_rank(c(fid = 3, svd = 3, bic = 3, pa = 2))
  expect_equal(out, list(rank = 3L, confidence = 0.75))
})

test_that(".consensus_rank() breaks ties towards the higher rank", {
  out <- .consensus_rank(c(2, 2, 3, 3))
  expect_equal(out$rank, 3L)
  expect_equal(out$confidence, 0.5)
})

test_that(".consensus_rank() gives confidence 1 for unanimous votes", {
  expect_equal(.consensus_rank(c(a = 4, b = 4))$confidence, 1)
})

test_that(".consensus_rank() ignores missing votes", {
  out <- .consensus_rank(c(fid = NA, svd = 2, bic = 2, pa = 3))
  expect_equal(out$rank, 2L)
  expect_equal(out$confidence, 2 / 3)
})

test_that(".consensus_rank() aborts when there are no usable votes", {
  expect_error(.consensus_rank(integer()), class = "moosaic-error-no_votes")
  expect_error(
    .consensus_rank(c(NA_real_, NA_real_)),
    class = "moosaic-error-no_votes"
  )
})
