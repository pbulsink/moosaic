#' Stack search results into one tibble
#'
#' @param hits List of data frames, one per query, each with an
#'   `unknown_name` attribute (see `.run_mspepsearch()`).
#'
#' @return A tibble with `component_id`, `hit_rank`, `name`, `cas`, `formula`,
#'   `mw`, `mf`, `rmf`, `prob` and `library_ri`; zero rows when there are no
#'   hits.
#'
#' @keywords internal
.parse_search_results <- function(hits) {
  pieces <- lapply(hits, \(h) {
    n <- nrow(h)
    if (n == 0L) {
      return(NULL)
    }
    col <- \(x, type) if (is.null(x)) rep(type, n) else x
    tibble::tibble(
      component_id = rep(attr(h, "unknown_name") %||% NA_character_, n),
      hit_rank = seq_len(n),
      name = as.character(col(h$name, NA_character_)),
      cas = as.character(col(h$cas, NA_character_)),
      formula = as.character(col(h$formula, NA_character_)),
      mw = as.numeric(col(h$mw, NA_real_)),
      mf = as.numeric(col(h$mf, NA_real_)),
      rmf = as.numeric(col(h$rmf, NA_real_)),
      prob = as.numeric(col(h$prob, NA_real_)),
      library_ri = as.numeric(col(h$ri, NA_real_))
    )
  })
  out <- do.call(rbind, pieces)
  if (is.null(out)) {
    out <- tibble::tibble(
      component_id = character(),
      hit_rank = integer(),
      name = character(),
      cas = character(),
      formula = character(),
      mw = numeric(),
      mf = numeric(),
      rmf = numeric(),
      prob = numeric(),
      library_ri = numeric()
    )
  }
  out
}
