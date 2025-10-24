# Fetch MEPS event files (RX, OB, OP, ER, IP) for selected years
# Requires: haven
# Use built-in minimal URL mapping for recent years, or provide a CSV mapping file with columns: year,event,url

fetch_meps_events <- function(years = 2000:2022, events = c('rx','ob','op','er','ip'), dest_dir = file.path('inst','extdata'), map_file = NULL){
  if (!requireNamespace('haven', quietly = TRUE)) stop("Install haven: install.packages('haven')")
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  # Built-in minimal map for recent years
  built_in <- list(
    `2019` = c(rx='https://meps.ahrq.gov/data_files/pufs/h206a/h206axpt.zip',
               ob='https://meps.ahrq.gov/data_files/pufs/h213a/h213axpt.zip',
               op='https://meps.ahrq.gov/data_files/pufs/h212a/h212axpt.zip',
               er='https://meps.ahrq.gov/data_files/pufs/h211a/h211axpt.zip',
               ip='https://meps.ahrq.gov/data_files/pufs/h210a/h210axpt.zip'),
    `2020` = c(rx='https://meps.ahrq.gov/data_files/pufs/h221a/h221axpt.zip',
               ob='https://meps.ahrq.gov/data_files/pufs/h228a/h228axpt.zip',
               op='https://meps.ahrq.gov/data_files/pufs/h227a/h227axpt.zip',
               er='https://meps.ahrq.gov/data_files/pufs/h226a/h226axpt.zip',
               ip='https://meps.ahrq.gov/data_files/pufs/h225a/h225axpt.zip'),
    `2021` = c(rx='https://meps.ahrq.gov/data_files/pufs/h231a/h231axpt.zip',
               ob='https://meps.ahrq.gov/data_files/pufs/h238a/h238axpt.zip',
               op='https://meps.ahrq.gov/data_files/pufs/h237a/h237axpt.zip',
               er='https://meps.ahrq.gov/data_files/pufs/h236a/h236axpt.zip',
               ip='https://meps.ahrq.gov/data_files/pufs/h235a/h235axpt.zip'),
    `2022` = c(rx='https://meps.ahrq.gov/data_files/pufs/h239a/h239axpt.zip',
               ob='https://meps.ahrq.gov/data_files/pufs/h246a/h246axpt.zip',
               op='https://meps.ahrq.gov/data_files/pufs/h245a/h245axpt.zip',
               er='https://meps.ahrq.gov/data_files/pufs/h244a/h244axpt.zip',
               ip='https://meps.ahrq.gov/data_files/pufs/h243a/h243axpt.zip')
  )
  ext_map <- NULL
  if (!is.null(map_file) && file.exists(map_file)) {
    ext_map <- try(utils::read.csv(map_file, stringsAsFactors = FALSE), silent = TRUE)
    if (inherits(ext_map, 'try-error')) ext_map <- NULL
  }
  missing <- list()
  for (yr in years) {
    for (ev in events) {
      url <- NULL
      if (!is.null(ext_map)) {
        hit <- subset(ext_map, year == yr & tolower(event) == tolower(ev))
        if (nrow(hit)) url <- hit$url[1]
      }
      if (is.null(url)) {
        evs <- built_in[[as.character(yr)]]
        if (!is.null(evs)) url <- evs[[ev]]
      }
      id <- sprintf('meps_%d_%s', yr, ev)
      if (is.null(url)) { message('No URL mapping for ', id, '; add to mapping CSV.'); next }
      zf <- tempfile(fileext = '.zip')
      ok <- try(utils::download.file(url, destfile = zf, mode = 'wb', quiet = TRUE), silent = TRUE)
      if (inherits(ok, 'try-error')) { message('Skip ', id, ' (download failed)'); next }
      ex <- tempfile(); utils::unzip(zf, exdir = ex)
      xpt <- list.files(ex, pattern = '\\.(xpt|XPT)$', full.names = TRUE)
      if (!length(xpt)) { message('Skip ', id, ' (no XPT found)'); next }
      dat <- try(haven::read_xpt(xpt[1]), silent = TRUE)
      if (inherits(dat, 'try-error')) { message('Skip ', id, ' (read_xpt failed)'); next }
      names(dat) <- tolower(names(dat))
      dat$dataset_id <- id
      if ('dupersid' %in% names(dat)) dat$patient_id <- dat$dupersid else dat$patient_id <- seq_len(nrow(dat))
      out <- file.path(dest_dir, paste0(id, '.csv'))
      utils::write.csv(dat, out, row.names = FALSE)
      message('Wrote ', out)
    }
  }
  invisible(TRUE)
}
