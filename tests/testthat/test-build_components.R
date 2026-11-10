test_that(".build_components() returns one component per fitted column", {
  fit <- fake_fit()
  fid <- fid_raw()
  comps <- .build_components(fit, fid, fake_window)
  expect_length(comps, 2L)
  expect_s3_class(comps[[1]], "moosaic_component")
  expect_equal(comps[[1]]$id, "w3_c1")
  expect_equal(comps[[1]]$window_id, 3L)
  expect_equal(comps[[1]]$rt, fid$rt[14])
  expect_equal(comps[[2]]$rt, fid$rt[26])
  expect_equal(names(comps[[1]]$spectrum), as.character(50:60))
  expect_equal(comps[[1]]$chromatogram$rt, fid$rt)
  expect_false(comps[[1]]$is_background)
  expect_equal(comps[[1]]$residual, 1.5)
})

test_that(".build_components() apportions the raw FID area and computes the FID/MS ratio", {
  fit <- fake_fit()
  fid <- fid_raw()
  comps <- .build_components(fit, fid, fake_window)
  total <- sum(vapply(comps, \(x) x$area_fid, numeric(1)))
  expect_equal(
    total,
    .integrate_trapezoid(fid$rt, fid$intensity),
    tolerance = 1e-8
  )
  expect_equal(
    comps[[1]]$fid_ms_ratio,
    comps[[1]]$area_fid / comps[[1]]$area_ms
  )
})

test_that(".build_components() flags the trailing background and gives it no FID area", {
  fit <- fake_fit(bg = TRUE)
  fid <- fid_raw()
  comps <- .build_components(fit, fid, fake_window, background = TRUE)
  expect_length(comps, 3L)
  expect_true(comps[[3]]$is_background)
  expect_true(is.na(comps[[3]]$area_fid))
  expect_equal(
    comps[[1]]$area_fid + comps[[2]]$area_fid,
    .integrate_trapezoid(fid$rt, fid$intensity),
    tolerance = 1e-8
  )
})

test_that(".build_components() aborts when the fit and FID window disagree", {
  expect_error(
    .build_components(fake_fit(), fid_raw(10), fake_window),
    class = "moosaic-error-bad_argument"
  )
})
