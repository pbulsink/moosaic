pk <- \(rt, h = rep(100, length(rt))) tibble::tibble(apex_rt = rt, height = h)

test_that(".estimate_delay_gcalignr() aborts when GCalignR is not installed", {
  local_mocked_bindings(requireNamespace = \(...) FALSE, .package = "base")
  expect_error(
    .estimate_delay_gcalignr(pk(c(5, 6)), pk(c(5, 6)), 0.2, 0.005),
    class = "moosaic-error-missing_package"
  )
})

test_that(".estimate_delay_gcalignr() recovers an offset of 0.05 within one step", {
  skip_if_not_installed("GCalignR")
  d <- .estimate_delay_gcalignr(
    pk(c(5, 10, 15, 20)),
    pk(c(5.05, 10.05, 15.05, 20.05)),
    max_delay = 0.2,
    step = 0.005
  )
  expect_equal(d, 0.05, tolerance = 0.005 / 0.05)
})

test_that(".estimate_delay_gcalignr() reports a negative delay when MS is earlier", {
  skip_if_not_installed("GCalignR")
  d <- .estimate_delay_gcalignr(
    pk(c(5, 10, 15, 20)),
    pk(c(4.96, 9.96, 14.96, 19.96)),
    max_delay = 0.2,
    step = 0.005
  )
  expect_equal(d, -0.04, tolerance = 0.1)
})

test_that(".estimate_delay_gcalignr() aborts with too few peaks", {
  skip_if_not_installed("GCalignR")
  expect_error(
    .estimate_delay_gcalignr(pk(5), pk(c(5, 6)), 0.2, 0.005),
    class = "moosaic-error-too_few_peaks"
  )
})
