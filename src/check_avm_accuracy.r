library(tidyverse)

source("src/unzip_data.r")
source("src/apply_types.r")

dict_assessor <- read_csv("data/dictionary_assessor.csv", show_col_types = FALSE)
dict_deed <- read_csv("data/dictionary_deed.csv", show_col_types = FALSE)
dict_avm <- read_csv("data/dictionary_avm.csv", show_col_types = FALSE)

data_assessor_month <- apply_types(data_assessor_month, dict_assessor)
data_deed <- apply_types(data_deed, dict_deed)
data_avm <- apply_types(data_avm, dict_avm)

if ("Fips" %in% names(data_avm) && !"FIPS" %in% names(data_avm)) {
  data_avm <- rename(data_avm, FIPS = Fips)
}

# Join deed and AVM to monthly assessor by PropertyID
matched <- data_assessor_month |>
  filter(!is.na(CurrentSaleTransactionId)) |>
  inner_join(
    data_deed |> select(PropertyID, FATransactionID, SaleAmt),
    by = c("PropertyID" = "PropertyID",
      "CurrentSaleTransactionId" = "FATransactionID")
  ) |>
  inner_join(
    data_avm |> select(PropertyID, FinalValue, LowValue, HighValue),
    by = "PropertyID"
  ) |>
  mutate(deed_price = as.numeric(SaleAmt))

cat(sprintf("Monthly assessor rows: %s\n",
  format(nrow(data_assessor_month), big.mark = ",")))
cat(sprintf("Matched to deed + AVM: %s\n\n",
  format(nrow(matched), big.mark = ",")))

median_price <- median(matched$deed_price, na.rm = TRUE)
cat(sprintf("Median deed sale price (matched set): $%s\n\n",
  format(median_price, big.mark = ",")))

format_mae <- function(mae, median_price) {
  sprintf("$%s (%.1f%% of median)",
    format(round(mae), big.mark = ","),
    100 * mae / median_price)
}

report_accuracy <- function(avm_col, deed_col, label) {
  both <- !is.na(avm_col) & !is.na(deed_col) & deed_col > 0
  n <- sum(both)
  if (n == 0) {
    cat(sprintf("%-40s no overlap\n", label))
    return(invisible(NULL))
  }
  errors <- avm_col[both] - deed_col[both]
  abs_errors <- abs(errors)
  mae <- mean(abs_errors)
  mdae <- median(abs_errors)
  mape <- mean(abs_errors / deed_col[both]) * 100
  mdape <- median(abs_errors / deed_col[both]) * 100
  bias <- mean(errors)

  cat(sprintf("%-40s n = %s\n", label, format(n, big.mark = ",")))
  cat(sprintf("  MAE:                %s\n", format_mae(mae, median_price)))
  cat(sprintf("  Median abs error:   %s\n", format_mae(mdae, median_price)))
  cat(sprintf("  MAPE:               %.1f%%\n", mape))
  cat(sprintf("  Median APE:         %.1f%%\n", mdape))
  cat(sprintf("  Mean bias:          $%s\n\n",
    format(round(bias), big.mark = ",")))
}

cat(strrep("=", 60), "\n")
cat("AVM ACCURACY vs DEED SALE PRICE\n")
cat(strrep("=", 60), "\n\n")

report_accuracy(matched$CurrentAVMValue, matched$deed_price,
  "Assessor AVM vs deed price")

report_accuracy(matched$FinalValue, matched$deed_price,
  "Standalone AVM vs deed price")

# Previous sale
matched_prev <- data_assessor_month |>
  filter(!is.na(PrevSaleTransactionId)) |>
  inner_join(
    data_deed |> select(PropertyID, FATransactionID, SaleAmt),
    by = c("PropertyID" = "PropertyID",
      "PrevSaleTransactionId" = "FATransactionID")
  ) |>
  inner_join(
    data_avm |> select(PropertyID, FinalValue),
    by = "PropertyID"
  ) |>
  mutate(deed_price = as.numeric(SaleAmt))

if (nrow(matched_prev) > 0) {
  cat(strrep("-", 60), "\n")
  cat("PREVIOUS SALE\n")
  cat(sprintf("Matched to deed + AVM: %s\n\n",
    format(nrow(matched_prev), big.mark = ",")))

  report_accuracy(matched_prev$CurrentAVMValue, matched_prev$deed_price,
    "Assessor AVM vs prev deed price")

  report_accuracy(matched_prev$FinalValue, matched_prev$deed_price,
    "Standalone AVM vs prev deed price")
}
