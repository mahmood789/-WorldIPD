# Fetch NHANES 2017-2018 patient-level tables as example IPD (Demographics and Labs)
# Read-only ingestion; writes to inst/extdata as CSV
# Requires: readr

fetch_nhanes_2017_2018 <- function(dest_dir = file.path("inst","extdata")){
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
  # Demographics: P_DEMO.XPT (SAS transport) — convert to CSV requires haven
  # To keep dependencies light, fetch CSV mirrors where available, otherwise instruct haven usage.
  message("Fetching NHANES 2017-2018 demographics requires haven to read XPT.")
  if (!requireNamespace("haven", quietly = TRUE)) stop("Install haven to read NHANES XPT files: install.packages('haven')")

  demo_xpt <- tempfile(fileext = ".xpt")
  demo_url <- "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.XPT"
  utils::download.file(demo_url, destfile = demo_xpt, mode = "wb", quiet = TRUE)
  demo <- haven::read_xpt(demo_xpt)
  # Standardize minimal columns
  names(demo) <- tolower(names(demo))
  demo$dataset_id <- 'nhanes_2017_2018_demo'
  demo$patient_id <- demo$seqn  # NHANES respondent sequence number
  out_demo <- file.path(dest_dir, 'nhanes_2017_2018_demo.csv')
  utils::write.csv(demo, out_demo, row.names = FALSE)
  message("Wrote ", out_demo)

  # Example lab: Total Cholesterol (TCHOL_J.XPT)
  lab_xpt <- tempfile(fileext = ".xpt")
  lab_url <- "https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/TCHOL_J.XPT"
  utils::download.file(lab_url, destfile = lab_xpt, mode = "wb", quiet = TRUE)
  lab <- haven::read_xpt(lab_xpt)
  names(lab) <- tolower(names(lab))
  lab$dataset_id <- 'nhanes_2017_2018_lab'
  lab$patient_id <- lab$seqn
  out_lab <- file.path(dest_dir, 'nhanes_2017_2018_lab.csv')
  utils::write.csv(lab, out_lab, row.names = FALSE)
  message("Wrote ", out_lab)

  invisible(list(demographics = out_demo, labs = out_lab))
}
