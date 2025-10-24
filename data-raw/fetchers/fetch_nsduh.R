# Fetch NSDUH public-use microdata (register-only stub)
# NSDUH public-use datasets often come as ASCII + SAS setup or SAS7BDAT; ingestion requires a parser.
# For now, register entries and manual download locations, then transform to CSV offline.

fetch_nsduh_register <- function(years = 2002:2022, dest_dir = file.path('inst','extdata')){
  message('NSDUH fetcher is a stub: add manual download + transform to CSV for each year.')
  invisible(TRUE)
}
