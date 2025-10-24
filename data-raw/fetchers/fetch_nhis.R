# Fetch NHIS (National Health Interview Survey) Sample Adult files (2019-2022)
# Requires: haven
# Writes CSVs to inst/extdata with patient_id derived from HHX-PX if available

fetch_nhis_sample_adult <- function(years = 2019:2022, dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  # NHIS downloads (2019+): e.g., https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/2019/samadult_2019.XPT
  base <- 'https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Datasets/NHIS/%s/samadult_%s.XPT'
  for (yr in years) {
    url <- sprintf(base, yr, yr)
    tf <- tempfile(fileext = '.xpt')
    ok <- try(utils::download.file(url, destfile = tf, mode = 'wb', quiet = TRUE), silent = TRUE)
    if (inherits(ok, 'try-error')) { message('Skip NHIS ', yr, ' (download failed)'); next }
    dat <- try(haven::read_xpt(tf), silent = TRUE)
    if (inherits(dat, 'try-error')) { message('Skip NHIS ', yr, ' (read_xpt failed)'); next }
    names(dat) <- tolower(names(dat))
    id <- paste0('nhis_', yr, '_samadult')
    dat$dataset_id <- id
    # Derive patient_id (NHIS typical: household (hhx), person (px) or unique identifier in newer files)
    if (all(c('hhx','px') %in% names(dat))) dat$patient_id <- paste0(dat$hhx, '-', dat$px) else if ('px' %in% names(dat)) dat$patient_id <- dat$px else dat$patient_id <- seq_len(nrow(dat))
    out <- file.path(dest_dir, paste0(id, '.csv'))
    utils::write.csv(dat, out, row.names = FALSE)
    message('Wrote ', out)
  }
  invisible(TRUE)
}
