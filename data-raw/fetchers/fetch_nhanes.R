# Fetch NHANES patient-level tables (Demographics) for multiple cycles as example IPD
# Requires: haven

fetch_nhanes_demo <- function(cycles = c(
  list(yr='1999_2000', suf='A'),
  list(yr='2001_2002', suf='B'),
  list(yr='2003_2004', suf='C'),
  list(yr='2005_2006', suf='D'),
  list(yr='2007_2008', suf='E'),
  list(yr='2009_2010', suf='F'),
  list(yr='2011_2012', suf='G'),
  list(yr='2013_2014', suf='H'),
  list(yr='2015_2016', suf='I'),
  list(yr='2017_2018', suf='J')
), dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  for (cc in cycles) {
    suf <- cc$suf; yr <- cc$yr
    id <- sprintf('nhanes_%s_demo', yr)
    url <- sprintf('https://wwwn.cdc.gov/Nchs/Nhanes/%s/DEMO_%s.XPT', if (suf %in% LETTERS[1:5]) '1999-2000' else yr, suf)
    # Note: NHANES URL patterns vary; fallback to 2017-2018 style if needed
    if (suf %in% c('J','I','H','G','F','E','D','C','B','A')) {
      # Try modern pattern first (2017-2018): DEMO_J.XPT
      url <- sprintf('https://wwwn.cdc.gov/Nchs/Nhanes/%s/DEMO_%s.XPT', yr, suf)
    }
    tf <- tempfile(fileext = '.xpt')
    ok <- try(utils::download.file(url, destfile=tf, mode='wb', quiet=TRUE), silent=TRUE)
    if (inherits(ok,'try-error')) { message('Skip ', id, ' (download failed)'); next }
    demo <- try(haven::read_xpt(tf), silent=TRUE)
    if (inherits(demo,'try-error')) { message('Skip ', id, ' (read_xpt failed)'); next }
    names(demo) <- tolower(names(demo))
    demo$dataset_id <- id
    if (!('seqn' %in% names(demo))) { message('Skip ', id, ' (seqn missing)'); next }
    demo$patient_id <- demo$seqn
    out <- file.path(dest_dir, paste0(id, '.csv'))
    utils::write.csv(demo, out, row.names=FALSE)
    message('Wrote ', out)
  }
  invisible(TRUE)
}
