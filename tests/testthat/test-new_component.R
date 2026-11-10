test_that(".new_component() builds a moosaic_component with the documented fields", {
  cmp <- .new_component(
    id = "w1_c1",
    window_id = 1L,
    rt = 1,
    chromatogram = list(rt = 1:2, intensity = 1:2),
    spectrum = c(`40` = 1),
    area_fid = 2,
    area_ms = 4,
    fid_ms_ratio = 0.5,
    residual = 1,
    explained_variance = 0.4,
    is_background = FALSE
  )
  expect_s3_class(cmp, "moosaic_component")
  expect_named(
    cmp,
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
})
