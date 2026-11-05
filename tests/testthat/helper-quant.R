# Identified (or not) analyte components in a moosaic_result, for quantify()
mk_qresult <- function(rt, area, name, formula, score = 900, ri = NA_real_) {
  n <- length(rt)
  ri <- rep_len(ri, n)
  comps <- lapply(seq_len(n), \(i) {
    cmp <- mk_comp(paste0("c", i), rt[i], c(`50` = 1))
    cmp$area_fid <- area[i]
    cmp$ri <- ri[i]
    cmp$name <- name[i]
    if (!is.na(name[i])) {
      cmp$hits <- tibble::tibble(
        component_id = cmp$id,
        hit_rank = 1L,
        name = name[i],
        formula = formula[i],
        mw = NA_real_,
        mf = score,
        final = score - 5,
        observed_ri = ri[i],
        library_ri = ri[i] + 1
      )
    }
    cmp
  })
  structure(
    list(
      components = comps,
      windows = NULL,
      identifications = tibble::tibble()
    ),
    class = "moosaic_result"
  )
}

# Peak table with the columns used by the ported fidms helpers
mk_peaks <- function(identified, C, H, O, ri = NULL, rt = NULL) {
  n <- length(C)
  tbl <- tibble::tibble(
    rt = rt %||% seq_len(n),
    ri = ri %||% seq_len(n) * 100,
    identified = identified,
    name = ifelse(identified, "known", NA_character_),
    formula = ifelse(
      identified,
      .build_formula(C, H, O),
      NA_character_
    ),
    mw = NA_real_,
    area = 1,
    C = as.numeric(C),
    H = as.numeric(H),
    O = as.numeric(O)
  )
  for (el in setdiff(.tracked_elements, c("C", "H", "O"))) {
    tbl[[el]] <- ifelse(identified, 0, NA_real_)
  }
  tbl
}

# A quantified, summarised result with known composition
mk_quantified <- function(style = "internal", ...) {
  f <- c("C7H16", "C8H18", "C6H6O", "CH2Cl2")
  nm <- c("n-heptane", "n-octane", "phenol", "Methylene chloride")
  mw <- .molecular_weight(lapply(f, .parse_formula))
  C <- .carbon_count(lapply(f, .parse_formula))
  res <- mk_qresult(
    rt = c(3, 5, 8, 12),
    area = 1000 * c(1, 2, 3, 4) * C / mw,
    name = nm,
    formula = f,
    ri = c(700, 800, 959, 1000)
  )
  res$alignment <- list(delay = 0.0123)
  info <- sample_info(
    "S1",
    sample_name = "Oil",
    project_code = "P9",
    analyst = "Zed",
    density = 0.8,
    methanol_wt_pct = 2,
    water_wt_pct = 1,
    report_date = "2026-02-03"
  )
  summarize_report(quantify(res, info, style = style, ...))
}
