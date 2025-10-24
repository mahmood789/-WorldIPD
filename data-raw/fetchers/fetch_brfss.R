# Fetch BRFSS (CDC Behavioral Risk Factor Surveillance System) annual IPD (2019-2022)
# Requires: haven
# Writes CSVs to inst/extdata, with patient_id derived from SEQNO when present

fetch_brfss <- function(years = 2019:2022, dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  base <- 'https://www.cdc.gov/brfss/annual_data/%s/files/LLCP%sXPT.zip'
  for (yr in years) {
    y2 <- substr(as.character(yr), 3, 4)
    url <- sprintf(base, yr, y2)
    tf <- tempfile(fileext = '.zip')
    ok <- try(utils::download.file(url, destfile = tf, mode = 'wb', quiet = TRUE), silent = TRUE)
    if (inherits(ok, 'try-error')) { message('Skip BRFSS ', yr, ' (download failed)'); next }
    exdir <- tempfile()
    utils::unzip(tf, exdir = exdir)
    xpt <- list.files(exdir, pattern = '\\.XPT$', full.names = TRUE, ignore.case = TRUE)
    if (!length(xpt)) { message('Skip BRFSS ', yr, ' (no XPT found)'); next }
    dat <- try(haven::read_xpt(xpt[1]), silent = TRUE)
    if (inherits(dat, 'try-error')) { message('Skip BRFSS ', yr, ' (read_xpt failed)'); next }
    names(dat) <- tolower(names(dat))
    id <- paste0('brfss_', yr)
    dat$dataset_id <- id
    if ('seqno' %in% names(dat)) dat$patient_id <- dat$seqno else dat$patient_id <- seq_len(nrow(dat))
    out <- file.path(dest_dir, paste0(id, '.csv'))
    utils::write.csv(dat, out, row.names = FALSE)
    message('Wrote ', out)
  }
  invisible(TRUE)
}
