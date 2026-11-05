pen <- c(N = 50, S = 50, Cl = 100, Br = 100, Si = 25, P = 100)
allowed <- c("C", "H", "O", "N", "S")

test_that(".element_penalty() charges per atom of penalised elements", {
  expect_equal(.element_penalty("C6H6", pen, allowed), 0)
  expect_equal(.element_penalty("C5H5N", pen, allowed), 50)
  expect_equal(.element_penalty("C2H3Cl3", pen, allowed), 300)
})

test_that(".element_penalty() is vectorised and treats NA formula as no penalty", {
  expect_equal(
    .element_penalty(c("C6H6", "C5H5N", NA), pen, allowed),
    c(0, 50, 0)
  )
})

test_that(".element_penalty() penalises elements neither allowed nor listed, per atom", {
  expect_equal(.element_penalty("CF4", pen, allowed), 400)
  expect_equal(.element_penalty("CF4", pen, allowed, default = 10), 40)
  expect_equal(.element_penalty("C2H3F3Cl", pen, allowed), 300 + 100)
})

test_that(".element_penalty() aborts on an unknown element", {
  expect_error(
    .element_penalty("C2H3Xx", pen, allowed),
    class = "moosaic-error-bad_formula"
  )
})
