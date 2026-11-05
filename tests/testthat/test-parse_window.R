test_that(".parse_window() accepts a one-row data frame and a list", {
  w <- tibble::tibble(window_id = 3L, start_rt = 1, end_rt = 2)
  expect_equal(.parse_window(w), list(window_id = 3L, start_rt = 1, end_rt = 2))
  expect_equal(
    .parse_window(list(start_rt = 1, end_rt = 2))$window_id,
    NA_integer_
  )
})

test_that(".parse_window() aborts on malformed windows", {
  expect_error(
    .parse_window(list(start_rt = 1)),
    class = "moosaic-error-bad_window"
  )
  expect_error(
    .parse_window(list(start_rt = 2, end_rt = 1)),
    class = "moosaic-error-bad_window"
  )
  expect_error(
    .parse_window(tibble::tibble(start_rt = 1:2, end_rt = 2:3)),
    class = "moosaic-error-bad_window"
  )
  expect_error(
    .parse_window(list(start_rt = "a", end_rt = 2)),
    class = "moosaic-error-bad_window"
  )
})
