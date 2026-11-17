library(tidyverse)

source("src/unzip_data.r")
source("src/apply_types.r")

datasets <- list(
  assessor = list(data = data_assessor, dict = "data/dictionary_assessor.csv"),
  assessor_month = list(data = data_assessor_month, dict = "data/dictionary_assessor.csv"),
  deed = list(data = data_deed, dict = "data/dictionary_deed.csv"),
  avm = list(data = data_avm, dict = "data/dictionary_avm.csv")
)

is_missing <- function(x) {
  is.na(x) | (is.character(x) & str_trim(x) == "")
}

compute_missingness <- function(df, dict) {
  dict <- dict |>
    filter(field_name %in% names(df)) |>
    mutate(r_type = parse_sql_type(type))

  n_rows <- nrow(df)

  dict |>
    rowwise() |>
    mutate(
      n_missing = sum(is_missing(df[[field_name]])),
      pct_missing = round(100 * n_missing / n_rows, 1)
    ) |>
    ungroup() |>
    select(field_name, r_type, n_missing, pct_missing) |>
    arrange(desc(pct_missing))
}

print_missingness <- function(miss) {
  cat(sprintf("%-35s %9s %7s %6s\n", "field", "r_type", "n_miss", "pct"))
  cat(strrep("-", 60), "\n")
  for (i in seq_len(nrow(miss))) {
    r <- miss[i, ]
    cat(sprintf(
      "%-35s %9s %7s %5.1f%%\n",
      str_trunc(r$field_name, 35),
      r$r_type,
      format(r$n_missing, big.mark = ","),
      r$pct_missing
    ))
  }
}

summarize_numeric <- function(df, dict) {
  numeric_cols <- dict |>
    filter(field_name %in% names(df), parse_sql_type(type) == "numeric") |>
    pull(field_name)

  if (length(numeric_cols) == 0) return(tibble())

  map_dfr(numeric_cols, \(col) {
    x <- df[[col]]
    tibble(
      field_name = col,
      n = sum(!is.na(x)),
      min = min(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      mean = mean(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE)
    )
  })
}

print_numeric <- function(num) {
  cat(sprintf("%-30s %7s %12s %12s %12s %12s\n",
    "field", "n", "min", "median", "mean", "max"))
  cat(strrep("-", 89), "\n")
  for (i in seq_len(nrow(num))) {
    r <- num[i, ]
    cat(sprintf(
      "%-30s %7s %12s %12s %12s %12s\n",
      str_trunc(r$field_name, 30),
      format(r$n, big.mark = ","),
      format(r$min, big.mark = ",", digits = 4),
      format(r$median, big.mark = ",", digits = 4),
      format(r$mean, big.mark = ",", digits = 4),
      format(r$max, big.mark = ",", digits = 4)
    ))
  }
}

for (name in names(datasets)) {
  cat("\n", strrep("=", 60), "\n")
  cat(" ", str_to_upper(name), "\n")
  cat(strrep("=", 60), "\n\n")

  dict <- read_csv(datasets[[name]]$dict, show_col_types = FALSE)
  df <- datasets[[name]]$data
  cat("Rows:", format(nrow(df), big.mark = ","), " Columns:", ncol(df), "\n\n")

  df <- apply_types(df, dict)

  missingness <- compute_missingness(df, dict)
  cat("-- Missingness --\n\n")
  print_missingness(missingness)

  numeric_summary <- summarize_numeric(df, dict)
  if (nrow(numeric_summary) > 0) {
    cat("\n-- Numeric summaries --\n\n")
    print_numeric(numeric_summary)
  }

  cat("\n")
}
