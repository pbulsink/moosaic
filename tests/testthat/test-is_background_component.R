test_that(".is_background_component() flags bleed ions and flat profiles", {
  mz <- 35:400
  bleed <- setNames(rep(0.01, length(mz)), mz)
  bleed[c("73", "207", "281")] <- 1
  peak <- exp(-0.5 * ((1:40 - 20) / 3)^2)
  expect_true(.is_background_component(peak, bleed))
  analyte <- setNames(rep(0, length(mz)), mz)
  analyte[c("91", "106", "77")] <- c(1, 0.8, 0.3)
  expect_false(.is_background_component(peak, analyte))
  expect_true(.is_background_component(rep(1, 40), analyte))
})
