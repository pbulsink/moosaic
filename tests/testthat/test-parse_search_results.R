
test_that(".parse_search_results() turns blank formulas into NA", {
  h <- data.frame(name = "x", formula = "", mf = 800)
  attr(h, "unknown_name") <- "c1"
  expect_true(is.na(.parse_search_results(list(h))$formula))
})
