targets <- tibble::tibble(
  target = c("a", "p"),
  type = c("hydrocarbon", "oxygenate")
)

test_that(".assign_target_rows() uses the nearest preceding target of the same type", {
  peaks <- tibble::tibble(O = c(0, 0, 1, 0, 1))
  matched <- c("a", NA, "p", NA, NA)
  expect_equal(.assign_target_rows(peaks, matched, targets), c(1, 1, 3, 1, 3))
})

test_that(".assign_target_rows() falls back to the first target when none precede", {
  peaks <- tibble::tibble(O = c(0, 0, 0))
  matched <- c(NA, NA, "a")
  expect_equal(.assign_target_rows(peaks, matched, targets), c(3, 3, 3))
})

test_that(".assign_target_rows() uses the other type when one type has no targets", {
  peaks <- tibble::tibble(O = c(0, 1, 0))
  expect_equal(
    .assign_target_rows(peaks, c("a", NA, NA), targets),
    c(1, 1, 1)
  )
  expect_equal(
    .assign_target_rows(peaks, c(NA, "p", NA), targets),
    c(2, 2, 2)
  )
})

test_that(".assign_target_rows() returns NA when no targets matched", {
  peaks <- tibble::tibble(O = c(0, 1))
  expect_equal(
    .assign_target_rows(peaks, c(NA_character_, NA), targets),
    c(NA_integer_, NA)
  )
})
