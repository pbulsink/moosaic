#' Polyarc mass relative to a reference peak
#'
#' Evaluates
#' \deqn{m_i = m_t \frac{F_i}{F_t} \frac{C_t}{C_i} \frac{M_i}{M_t}}
#' where `F` is the raw FID area, `C` the carbon count and `M` the molar mass.
#'
#' @param area,carbon,mw FID area, carbon count and molar mass of the peaks.
#' @param ref_area,ref_carbon,ref_mw Same quantities for the reference peak.
#' @param ref_mass Mass (or amount) of the reference peak; 1 gives relative
#'   mass.
#'
#' @return Numeric vector of masses on the scale of `ref_mass`. `NA` where
#'   `carbon` is not positive or `ref_area` is not positive.
#'
#' @keywords internal
.polyarc_mass <- function(
  area,
  carbon,
  mw,
  ref_area,
  ref_carbon,
  ref_mw,
  ref_mass = 1
) {
  out <- ref_mass * (area / ref_area) * (ref_carbon / carbon) * (mw / ref_mw)
  bad <- !(carbon > 0 & ref_area > 0)
  out[rep_len(bad, length(out))] <- NA_real_
  out
}
