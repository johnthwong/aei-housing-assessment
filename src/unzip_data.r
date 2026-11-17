unzip_data <- function(path, name) {
  extracted <- unzip(path, exdir = tempdir(), overwrite = TRUE)
  data <- data.table::fread(
    extracted,
    sep = "|", colClasses = "character"
  ) |>
    as.data.frame()

  assign(paste0("data_", name), data, envir = .GlobalEnv)
}

paths <- data.frame(
  names = c("assessor", "assessor_month", "deed", "avm"),
  paths = c(
    "data/Prop01003.txt.zip",
    "data/Prop01003_update.txt.zip",
    "data/Deed01003.txt.zip",
    "data/AVM_Power01003.txt.zip"
  )
)

for (i in seq_len(nrow(paths))) unzip_data(paths$paths[i], paths$names[i])
