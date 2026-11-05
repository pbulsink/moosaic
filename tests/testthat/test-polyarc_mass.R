test_that(".polyarc_mass() returns the reference mass for the reference peak", {
  expect_equal(.polyarc_mass(50, 7, 100, 50, 7, 100, ref_mass = 3), 3)
})

test_that(".polyarc_mass() applies the area, carbon and molar mass ratios", {
  out <- .polyarc_mass(200, 4, 60, 100, 8, 120, ref_mass = 10)
  expect_equal(out, 10 * (200 / 100) * (8 / 4) * (60 / 120))
})

test_that(".polyarc_mass() halves when the carbon count doubles", {
  one <- .polyarc_mass(100, 4, 80, 100, 4, 80)
  two <- .polyarc_mass(100, 8, 80, 100, 4, 80)
  expect_equal(two, one / 2)
})

test_that(".polyarc_mass() is vectorised", {
  out <- .polyarc_mass(c(100, 200), c(4, 4), c(80, 80), 100, 4, 80)
  expect_equal(out, c(1, 2))
})

test_that(".polyarc_mass() gives NA for a zero carbon count or a non-positive reference area", {
  expect_true(is.na(.polyarc_mass(100, 0, 18, 100, 4, 80)))
  expect_true(is.na(.polyarc_mass(100, 4, 80, 0, 4, 80)))
})
