# Fetch CPS ASEC person-level public-use (recent years; mapping fragile)
# Requires: readr

fetch_cps_asec <- function(years = 2019:2023, dest_dir = file.path('inst','extdata')){
  if (!requireNamespace('readr', quietly = TRUE)) stop("Install readr: install.packages('readr')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  # Minimal mapping for illustrative fetch
  url_map <- list(
    `2019` = 'https://www2.census.gov/programs-surveys/cps/datasets/2019/march/asec2019_csv.zip',
    `2020` = 'https://www2.census.gov/programs-surveys/cps/datasets/2020/march/asec2020_csv.zip',
    `2021` = 'https://www2.census.gov/programs-surveys/cps/datasets/2021/march/asec2021_csv.zip',
    `2022` = 'https://www2.census.gov/programs-surveys/cps/datasets/2022/march/asec2022_csv.zip',
    `2023` = 'https://www2.census.gov/programs-surveys/cps/datasets/2023/march/asec2023_csv.zip'
  )
  for (yr in years) {
    id <- sprintf('cps_asec_%d', yr)
    url <- url_map[[as.character(yr)]]
    if (is.null(url)) { message('No URL mapping for ', id); next }
    zf <- tempfile(fileext = '.zip')
    ok <- try(utils::download.file(url, destfile = zf, mode = 'wb', quiet = TRUE), silent = TRUE)
    if (inherits(ok, 'try-error')) { message('Skip ', id, ' (download failed)'); next }
    ex <- tempfile(); utils::unzip(zf, exdir = ex)
    csvs <- list.files(ex, pattern = '(?i).*\\.csv$', full.names = TRUE)
    if (!length(csvs)) { message('Skip ', id, ' (no CSV found)'); next }
    # Combine person-level CSVs heuristically
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
    if ('h_idnum' %in% nm) out$patient_id <- out$h_idnum else out$patient_id <- seq_len(nrow(out))
    utils::write.csv(out, file.path(dest_dir, paste0(id,'.csv')), row.names = FALSE)
    message('Wrote ', file.path(dest_dir, paste0(id,'.csv')))
  }
  invisible(TRUE)
}
