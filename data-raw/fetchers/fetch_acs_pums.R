# Fetch ACS PUMS person files (1-Year) for selected years (2014+ pattern)
# Requires: readr

fetch_acs_pums <- function(years = 2014:2024, dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('readr', quietly = TRUE)) stop("Install readr: install.packages('readr')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  for (yr in years) {
    id <- sprintf('acs_pums_%d_1y', yr)
    url <- sprintf('https://www2.census.gov/programs-surveys/acs/data/pums/%d/1-Year/csv_pus.zip', yr)
    zf <- tempfile(fileext = '.zip')
    ok <- try(utils::download.file(url, destfile = zf, mode = 'wb', quiet = TRUE), silent = TRUE)
    if (inherits(ok, 'try-error')) { message('Skip ', id, ' (download failed: ', url, ')'); next }
    ex <- tempfile(); utils::unzip(zf, exdir = ex)
    # Look for person CSVs (common patterns: psam_p*.csv)
    csvs <- list.files(ex, pattern = '(?i)psam_p.*\\.csv$|pus.*\\.csv$', full.names = TRUE)
    if (!length(csvs)) { message('Skip ', id, ' (no person CSV found)'); next }
    # Read and bind a manageable subset (full bind can be huge; here we concatenate)
    out <- NULL
    for (f in csvs) {
      dat <- try(readr::read_csv(f, show_col_types = FALSE), silent = TRUE)
      if (inherits(dat,'try-error')) next
      out <- if (is.null(out)) dat else try(suppressWarnings(dplyr::bind_rows(out, dat)), silent = TRUE)
      if (inherits(out,'try-error')) { out <- dat }
    }
    if (is.null(out)) { message('Skip ', id, ' (failed to read CSVs)'); next }
    nm <- tolower(names(out)); names(out) <- nm
    out$dataset_id <- id
    if ('serialno' %in% nm) out$patient_id <- out$serialno else out$patient_id <- seq_len(nrow(out))
    utils::write.csv(out, file.path(dest_dir, paste0(id,'.csv')), row.names = FALSE)
    message('Wrote ', file.path(dest_dir, paste0(id,'.csv')))
  }
  invisible(TRUE)
}
