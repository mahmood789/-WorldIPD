# Fetch NHANES lab modules across cycles (register-friendly, robust to failures)
# Requires: haven
# modules: vector of module code stems used by NHANES (e.g., TCHOL, GLU, HDL, TRIG, A1C)
# cycles: data.frame with yr (e.g., 2017_2018) and suf (A..J)

fetch_nhanes_labs <- function(modules = c('TCHOL','GLU','HDL','TRIG','A1C'),
                              cycles = data.frame(yr=c('1999_2000','2001_2002','2003_2004','2005_2006','2007_2008','2009_2010','2011_2012','2013_2014','2015_2016','2017_2018'),
                                                  suf=LETTERS[1:10], stringsAsFactors = FALSE),
                              dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  for (i in seq_len(nrow(cycles))) {
    yr <- cycles$yr[i]; suf <- cycles$suf[i]
    for (mod in modules) {
      id <- sprintf('nhanes_%s_lab_%s', yr, tolower(mod))
      # NHANES URL pattern: https://wwwn.cdc.gov/Nchs/Nhanes/<yr>/<mod>_<suf>.XPT
      url <- sprintf('https://wwwn.cdc.gov/Nchs/Nhanes/%s/%s_%s.XPT', yr, toupper(mod), suf)
      tf <- tempfile(fileext = '.xpt')
      ok <- try(utils::download.file(url, destfile = tf, mode = 'wb', quiet = TRUE), silent = TRUE)
      if (inherits(ok, 'try-error')) { message('Skip ', id, ' (download failed: ', url, ')'); next }
      dat <- try(haven::read_xpt(tf), silent = TRUE)
      if (inherits(dat, 'try-error')) { message('Skip ', id, ' (read_xpt failed)'); next }
      names(dat) <- tolower(names(dat))
      dat$dataset_id <- id
      # Derive patient_id — NHANES respondent sequence number (seqn)
      if ('seqn' %in% names(dat)) dat$patient_id <- dat$seqn else dat$patient_id <- seq_len(nrow(dat))
      out <- file.path(dest_dir, paste0(id, '.csv'))
      utils::write.csv(dat, out, row.names = FALSE)
      message('Wrote ', out)
    }
  }
  invisible(TRUE)
}
