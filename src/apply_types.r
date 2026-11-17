library(tidyverse)

parse_sql_type <- function(type_str) {
  type_str <- str_to_lower(str_trim(type_str))
  type_str <- str_remove(type_str, "\\(.*\\)")
  case_match(
    type_str,
    c("int", "bigint") ~ "numeric",
    c("float", "real", "numeric") ~ "numeric",
    "date" ~ "date",
    "timestamp" ~ "date",
    .default = "character"
  )
}

apply_types <- function(df, dict, write_csv_path = NULL) {
  dict <- dict |>
    filter(field_name %in% names(df)) |>
    mutate(r_type = parse_sql_type(type))

  for (i in seq_len(nrow(dict))) {
    col <- dict$field_name[i]
    r_type <- dict$r_type[i]
    if (r_type == "numeric") {
      df[[col]] <- suppressWarnings(as.numeric(df[[col]]))
    } else if (r_type == "date") {
      df[[col]] <- suppressWarnings(as.Date(df[[col]], format = "%Y%m%d"))
    }
  }

  if (!is.null(write_csv_path)) {
    dir.create(dirname(write_csv_path), recursive = TRUE, showWarnings = FALSE)
    write_csv(df, write_csv_path)
  }

  return(df)
}
