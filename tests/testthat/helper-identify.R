mk_comp <- function(id, rt, spectrum) {
  .new_component(
    id = id,
    window_id = 1L,
    rt = rt,
    chromatogram = list(rt = 1:3, intensity = c(0, 1, 0)),
    spectrum = spectrum,
    area_fid = 1,
    area_ms = 1,
    fid_ms_ratio = 1,
    residual = 1,
    explained_variance = 0.5,
    is_background = FALSE
  )
}

# Mock for .run_mspepsearch(): per-query data frames carrying `unknown_name`
mock_search <- function(table) {
  function(queries) {
    lapply(queries, \(q) {
      df <- table[[q$name]]
      attr(df, "unknown_name") <- q$name
      df
    })
  }
}

mk_hits <- function(name, mf, formula, ri) {
  data.frame(
    name = name,
    mf = mf,
    rmf = mf,
    prob = 10,
    formula = formula,
    mw = 100,
    inchikey = NA_character_,
    cas = NA_character_,
    ri = ri
  )
}

cal <- tibble::tibble(rt = c(1, 5, 10), ri = c(600, 800, 1000))
