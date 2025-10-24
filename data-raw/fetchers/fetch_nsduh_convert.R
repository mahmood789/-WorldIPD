# Convert NSDUH public-use files to CSV (manual converter)
# For each year, download ASCII/SAS setup files from SAMHSA and convert using setup metadata.
# This stub shows how to read a SAS7BDAT file if present.

fetch_nsduh_convert <- function(year, sas7bdat_path = NULL, out_dir = file.path('inst','extdata')){
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  if (is.null(sas7bdat_path) || !file.exists(sas7bdat_path)) stop('Provide sas7bdat_path for NSDUH ') 
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  dat <- try(haven::read_sas(sas7bdat_path), silent = TRUE)
  if (inherits(dat,'try-error')) stop('Failed to read SAS7BDAT: ', sas7bdat_path)
  names(dat) <- tolower(names(dat))
  id <- sprintf('nsduh_%d', year)
  dat$dataset_id <- id
  dat$patient_id <- seq_len(nrow(dat))
  out <- file.path(out_dir, paste0(id, '.csv'))
  utils::write.csv(dat, out, row.names = FALSE)
  message('Wrote ', out)
  invisible(out)
}
