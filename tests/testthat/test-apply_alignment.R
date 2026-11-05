test_that(".apply_alignment() subtracts the delay without altering the input", {
  rt <- c(1, 2, 3)
  expect_equal(.apply_alignment(rt, 0.05), c(0.95, 1.95, 2.95))
  expect_equal(rt, c(1, 2, 3))
  expect_equal(.apply_alignment(rt, 0), rt)
})
