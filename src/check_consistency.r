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

if ("Fips" %in% names(data_avm) && !"FIPS" %in% names(data_avm)) {
  data_avm <- rename(data_avm, FIPS = Fips)
}

# -- 1. AVM deviation: assessor vs standalone AVM ----------------------------

check_avm_deviation <- function(assessor, avm) {
  cat("\n", strrep("=", 60), "\n")
  cat("AVM DEVIATION: assessor vs standalone AVM\n")
  cat(strrep("=", 60), "\n\n")

  joined <- inner_join(
    assessor |> select(PropertyID, CurrentAVMValue, vLowValue, vHighValue,
      vConfidenceScore, vStandardDeviation, vValuationDate),
    avm |> select(PropertyID, FinalValue, LowValue, HighValue,
      ConfidenceScore, StandardDeviation, ValuationDate),
    by = "PropertyID"
  )

  cat(sprintf("Matched properties: %s\n\n", format(nrow(joined), big.mark = ",")))

  field_pairs <- list(
    list("CurrentAVMValue", "FinalValue"),
    list("vLowValue", "LowValue"),
    list("vHighValue", "HighValue"),
    list("vConfidenceScore", "ConfidenceScore"),
    list("vStandardDeviation", "StandardDeviation")
  )

  cat(sprintf("%-25s %25s %8s %10s %12s\n",
    "assessor field", "avm field", "n_diff", "pct_diff", "mean_abs_diff"))
  cat(strrep("-", 82), "\n")

  for (pair in field_pairs) {
    a <- joined[[pair[[1]]]]
    b <- joined[[pair[[2]]]]
    both_present <- !is.na(a) & !is.na(b)
    n_compare <- sum(both_present)
    if (n_compare == 0) {
      cat(sprintf("%-25s %25s %8s %10s %12s\n",
        pair[[1]], pair[[2]], "0", "NA", "NA"))
      next
    }
    diffs <- a[both_present] != b[both_present]
    n_diff <- sum(diffs)
    pct_diff <- round(100 * n_diff / n_compare, 1)
    mean_abs <- round(mean(abs(a[both_present] - b[both_present])), 2)
    cat(sprintf("%-25s %25s %8s %9.1f%% %12s\n",
      pair[[1]], pair[[2]],
      format(n_diff, big.mark = ","),
      pct_diff,
      format(mean_abs, big.mark = ",")))
  }

  # Valuation date comparison (character vs Date)
  a_date <- as.Date(joined$vValuationDate, format = "%Y%m%d")
  b_date <- joined$ValuationDate
  both_present <- !is.na(a_date) & !is.na(b_date)
  n_compare <- sum(both_present)
  n_diff <- sum(a_date[both_present] != b_date[both_present])
  pct_diff <- if (n_compare > 0) round(100 * n_diff / n_compare, 1) else NA
  cat(sprintf("%-25s %25s %8s %9s%%\n",
    "vValuationDate", "ValuationDate",
    format(n_diff, big.mark = ","),
    if (is.na(pct_diff)) "NA" else format(pct_diff, nsmall = 1)))
  cat("\n")
}

# -- 2. Transaction match: assessor vs deed ---------------------------------

check_transactions <- function(assessor, deed, assessor_name) {
  cat("\n", strrep("=", 60), "\n")
  cat(sprintf("TRANSACTION MATCH: %s vs deed\n", assessor_name))
  cat(strrep("=", 60), "\n\n")

  # Current sale
  current <- assessor |>
    filter(!is.na(CurrentSaleTransactionId)) |>
    select(PropertyID, CurrentSaleTransactionId, CurrentSaleRecordingDate,
      CurrentSalesPrice, CurrentSaleDocumentType)

  deed_txn <- deed |>
    select(PropertyID, FATransactionID, RecordingDate, SaleAmt, DocumentType)

  current_joined <- inner_join(
    current, deed_txn,
    by = c("PropertyID" = "PropertyID",
      "CurrentSaleTransactionId" = "FATransactionID")
  )

  cat("CURRENT SALE\n")
  cat(sprintf("  Assessor rows with a current transaction ID: %s\n",
    format(nrow(current), big.mark = ",")))
  cat(sprintf("  Matched to deed by PropertyID + TransactionID: %s\n",
    format(nrow(current_joined), big.mark = ",")))
  cat(sprintf("  Unmatched: %s\n\n",
    format(nrow(current) - nrow(current_joined), big.mark = ",")))

  if (nrow(current_joined) > 0) {
    compare_field <- function(a, b, label) {
      both <- !is.na(a) & !is.na(b)
      n <- sum(both)
      if (n == 0) return(cat(sprintf("  %-30s no overlap\n", label)))
      n_match <- sum(as.character(a[both]) == as.character(b[both]))
      cat(sprintf("  %-30s %s / %s match (%.1f%%)\n",
        label, format(n_match, big.mark = ","), format(n, big.mark = ","),
        100 * n_match / n))
    }

    compare_field(current_joined$CurrentSaleRecordingDate,
      current_joined$RecordingDate, "RecordingDate")
    compare_field(current_joined$CurrentSalesPrice,
      as.numeric(current_joined$SaleAmt), "SalesPrice")
    compare_field(current_joined$CurrentSaleDocumentType,
      current_joined$DocumentType, "DocumentType")
  }

  # Previous sale
  previous <- assessor |>
    filter(!is.na(PrevSaleTransactionId)) |>
    select(PropertyID, PrevSaleTransactionId, PrevSaleRecordingDate,
      PrevSalesPrice, PrevSaleDocumentType)

  previous_joined <- inner_join(
    previous, deed_txn,
    by = c("PropertyID" = "PropertyID",
      "PrevSaleTransactionId" = "FATransactionID")
  )

  cat("\nPREVIOUS SALE\n")
  cat(sprintf("  Assessor rows with a previous transaction ID: %s\n",
    format(nrow(previous), big.mark = ",")))
  cat(sprintf("  Matched to deed by PropertyID + TransactionID: %s\n",
    format(nrow(previous_joined), big.mark = ",")))
  cat(sprintf("  Unmatched: %s\n\n",
    format(nrow(previous) - nrow(previous_joined), big.mark = ",")))

  if (nrow(previous_joined) > 0) {
    compare_field(previous_joined$PrevSaleRecordingDate,
      previous_joined$RecordingDate, "RecordingDate")
    compare_field(previous_joined$PrevSalesPrice,
      as.numeric(previous_joined$SaleAmt), "SalesPrice")
    compare_field(previous_joined$PrevSaleDocumentType,
      previous_joined$DocumentType, "DocumentType")
  }

  cat("\n")
}

check_avm_deviation(data_assessor, data_avm)
check_transactions(data_assessor_month, data_deed, "assessor_month")
check_transactions(data_assessor, data_deed, "assessor")
