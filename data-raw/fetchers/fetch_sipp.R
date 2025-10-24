# Fetch SIPP public-use microdata using a mapping CSV
# mapping CSV columns: year,file,url  (file is a label like core, topical, person, etc.)
# Requires: readr

fetch_sipp <- function(map_file = 'data-raw/fetchers/sipp_url_map.csv', dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('readr', quietly = TRUE)) stop("Install readr: install.packages('readr')")
  if (!file.exists(map_file)) stop('Mapping CSV not found: ', map_file)
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  mp <- try(utils::read.csv(map_file, stringsAsFactors = FALSE), silent = TRUE)
  if (inherits(mp,'try-error') || !all(c('year','file','url') %in% names(mp))) stop('Invalid SIPP map CSV; expected year,file,url')
  for (i in seq_len(nrow(mp))) {
    yr <- mp$year[i]; lab <- mp$file[i]; url <- mp$url[i]
    id <- sprintf('sipp_%s_%s', yr, lab)
    tf <- tempfile(fileext = tools::file_ext(url))
    ok <- try(utils::download.file(url, destfile = tf, mode = 'wb', quiet = TRUE), silent = TRUE)
    if (inherits(ok,'try-error')) { message('Skip ', id, ' (download failed)'); next }
    # If it is zip, unzip, then look for CSV
    if (grepl('\
zip$', url, ignore.case = TRUE)) {
      ex <- tempfile(); utils::unzip(tf, exdir = ex)
      csvs <- list.files(ex, pattern = '\\.(csv|CSV)$', full.names = TRUE)
      if (!length(csvs)) { message('Skip ', id, ' (no CSV in ZIP)'); next }
      out <- NULL
      for (f in csvs) {
        dat <- try(readr::read_csv(f, show_col_types = FALSE), silent = TRUE)
        if (inherits(dat,'try-error')) next
        # Bind or take first
        out <- if (is.null(out)) dat else try(suppressWarnings(dplyr::bind_rows(out, dat)), silent = TRUE)
        if (inherits(out,'try-error')) out <- dat
      }
      if (is.null(out)) { message('Skip ', id, ' (failed to read ZIP CSVs)'); next }
      nm <- tolower(names(out)); names(out) <- nm
      out$dataset_id <- id
      if ('ssuid' %in% nm && 'epppnum' %in% nm) out$patient_id <- paste0(out$ssuid, '-', out$epppnum) else out$patient_id <- seq_len(nrow(out))
      utils::write.csv(out, file.path(dest_dir, paste0(id, '.csv')), row.names = FALSE)
      message('Wrote ', file.path(dest_dir, paste0(id, '.csv')))
    } else if (grepl('\
csv$', url, ignore.case = TRUE)) {
      dat <- try(readr::read_csv(tf, show_col_types = FALSE), silent = TRUE)
      if (inherits(dat,'try-error')) { message('Skip ', id, ' (failed to read CSV)'); next }
      nm <- tolower(names(dat)); names(dat) <- nm
      dat$dataset_id <- id
      if ('ssuid' %in% nm && 'epppnum' %in% nm) dat$patient_id <- paste0(dat$ssuid, '-', dat$epppnum) else dat$patient_id <- seq_len(nrow(dat))
      utils::write.csv(dat, file.path(dest_dir, paste0(id, '.csv')), row.names = FALSE)
      message('Wrote ', file.path(dest_dir, paste0(id, '.csv')))
    } else {
      message('Skip ', id, ' (unknown file type)')
    }
  }
  invisible(TRUE)
}
