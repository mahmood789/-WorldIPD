# Fetch MEPS Full-Year Consolidated files (selected years) as example IPD
# Requires: haven
# Writes CSVs to inst/extdata

fetch_meps_fyc <- function(years = c(2019, 2020, 2021, 2022), dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  # Minimal lookup table for FYC XPT URLs (AHRQ naming conventions)
  tab <- data.frame(
    year = c(2019, 2020, 2021, 2022),
    url  = c(
      'https://meps.ahrq.gov/data_files/pufs/h209/h209xpt.zip',
      'https://meps.ahrq.gov/data_files/pufs/h224/h224xpt.zip',
      'https://meps.ahrq.gov/data_files/pufs/h233/h233xpt.zip',
      'https://meps.ahrq.gov/data_files/pufs/h241/h241xpt.zip'
    ),
    stringsAsFactors = FALSE
  )
  for (yr in years) {
    row <- tab[tab$year == yr, , drop = FALSE]
    if (!nrow(row)) { message('No URL mapping for MEPS year ', yr); next }
    id <- paste0('meps_', yr, '_fyc')
    zf <- tempfile(fileext = '.zip')
    ok <- try(utils::download.file(row$url, destfile = zf, mode = 'wb', quiet = TRUE), silent = TRUE)
    if (inherits(ok, 'try-error')) { message('Skip ', id, ' (download failed)'); next }
    ex <- tempfile(); utils::unzip(zf, exdir = ex)
    xpt <- list.files(ex, pattern = '\\.(xpt|XPT)$', full.names = TRUE)
    if (!length(xpt)) { message('Skip ', id, ' (no XPT found)'); next }
    dat <- try(haven::read_xpt(xpt[1]), silent = TRUE)
    if (inherits(dat, 'try-error')) { message('Skip ', id, ' (read_xpt failed)'); next }
    names(dat) <- tolower(names(dat))
    dat$dataset_id <- id
    # derive patient_id (dupersid if available)
    if ('dupersid' %in% names(dat)) dat$patient_id <- dat$dupersid else dat$patient_id <- seq_len(nrow(dat))
    out <- file.path(dest_dir, paste0(id, '.csv'))
    utils::write.csv(dat, out, row.names = FALSE)
    message('Wrote ', out)
  }
  invisible(TRUE)
}
