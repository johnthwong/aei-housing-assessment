library(tidyverse)

source("src/unzip_data.r")
source("src/apply_types.r")

dict_assessor <- read_csv("data/dictionary_assessor.csv", show_col_types = FALSE)
dict_deed <- read_csv("data/dictionary_deed.csv", show_col_types = FALSE)
dict_avm <- read_csv("data/dictionary_avm.csv", show_col_types = FALSE)

data_assessor <- apply_types(data_assessor, dict_assessor)
data_assessor_month <- apply_types(data_assessor_month, dict_assessor)
data_deed <- apply_types(data_deed, dict_deed)
data_avm <- apply_types(data_avm, dict_avm)

# AVM dictionary uses "Fips"; assessor and deed use "FIPS"
if ("Fips" %in% names(data_avm) && !"FIPS" %in% names(data_avm)) {
  data_avm <- rename(data_avm, FIPS = Fips)
}

check_merge <- function(df_left, df_right, name_left, name_right, by_col) {
  cat(sprintf("\n%s x %s  (by %s)\n", name_left, name_right, by_col))
  cat(strrep("-", 50), "\n")

  n_left <- nrow(df_left)
  n_right <- nrow(df_right)
  cat(sprintf("  %-20s %s rows\n", name_left, format(n_left, big.mark = ",")))
  cat(sprintf("  %-20s %s rows\n", name_right, format(n_right, big.mark = ",")))

  keys_left <- df_left[[by_col]]
  keys_right <- df_right[[by_col]]

  unique_left <- n_distinct(keys_left)
  unique_right <- n_distinct(keys_right)
  cat(sprintf("  %-20s %s distinct keys\n", name_left, format(unique_left, big.mark = ",")))
  cat(sprintf("  %-20s %s distinct keys\n", name_right, format(unique_right, big.mark = ",")))

  left_is_unique <- unique_left == n_left
  right_is_unique <- unique_right == n_right

  merge_type <- case_when(
    left_is_unique & right_is_unique ~ "one-to-one",
    left_is_unique & !right_is_unique ~ "one-to-many",
    !left_is_unique & right_is_unique ~ "many-to-one",
    TRUE ~ "many-to-many"
  )
  cat(sprintf("  merge type: %s\n", merge_type))

  shared_keys <- intersect(unique(keys_left), unique(keys_right))
  only_left <- setdiff(unique(keys_left), unique(keys_right))
  only_right <- setdiff(unique(keys_right), unique(keys_left))
  cat(sprintf("  shared keys: %s\n", format(length(shared_keys), big.mark = ",")))
  cat(sprintf("  only in %-10s %s\n", paste0(name_left, ":"), format(length(only_left), big.mark = ",")))
  cat(sprintf("  only in %-10s %s\n", paste0(name_right, ":"), format(length(only_right), big.mark = ",")))

  return(invisible(merge_type))
}

pairs <- list(
  list(data_assessor, data_deed, "assessor", "deed"),
  list(data_assessor, data_avm, "assessor", "avm"),
  list(data_assessor, data_assessor_month, "assessor", "assessor_month"),
  list(data_deed, data_avm, "deed", "avm"),
  list(data_deed, data_assessor_month, "deed", "assessor_month"),
  list(data_avm, data_assessor_month, "avm", "assessor_month")
)

cat("MERGE DIAGNOSTICS (by PropertyID)\n")
cat(strrep("=", 50), "\n")

for (p in pairs) {
  check_merge(p[[1]], p[[2]], p[[3]], p[[4]], "PropertyID")
}
