test_that("components_to_tibble() returns one row per component with the field columns", {
  comps <- .build_components(
    fake_fit(bg = TRUE),
    fid_raw(),
    fake_window,
    background = TRUE
  )
  tb <- components_to_tibble(comps)
  expect_s3_class(tb, "tbl_df")
  expect_equal(nrow(tb), 3L)
  expect_named(
    tb,
    c(
      "id",
      "window_id",
      "rt",
      "chromatogram",
      "spectrum",
      "area_fid",
      "area_ms",
      "fid_ms_ratio",
      "residual",
      "explained_variance",
      "is_background"
    )
  )
  expect_type(tb$chromatogram, "list")
  expect_equal(tb$is_background, c(FALSE, FALSE, TRUE))
})

test_that("components_to_tibble() accepts a moosaic_result and an empty list", {
  comps <- .build_components(fake_fit(), fid_raw(), fake_window)
  res <- structure(list(components = comps), class = "moosaic_result")
  expect_equal(nrow(components_to_tibble(res)), 2L)
  expect_equal(nrow(components_to_tibble(list())), 0L)
  expect_error(components_to_tibble(1), class = "moosaic-error-bad_argument")
})
