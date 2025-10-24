options(repos = "https://cloud.r-project.org")
if (!requireNamespace('haven', quietly = TRUE)) install.packages('haven')
if (!requireNamespace('readr', quietly = TRUE)) install.packages('readr')

source("data-raw/fetchers/fetch_nhanes.R")
source("data-raw/fetchers/fetch_nhanes_labs.R")
source("data-raw/fetchers/fetch_brfss.R")
source("data-raw/fetchers/fetch_nhis.R")
source("data-raw/fetchers/fetch_meps.R")
source("data-raw/fetchers/fetch_meps_events.R")
source("data-raw/fetchers/fetch_acs_pums.R")
source("data-raw/fetchers/fetch_cps_asec.R")

message("Fetching NHANES DEMO ..."); try(fetch_nhanes_demo(), silent = TRUE)
message("Fetching NHANES labs (extended) ..."); try(fetch_nhanes_labs(), silent = TRUE)
message("Fetching BRFSS 2011-2022 ..."); try(fetch_brfss(2011:2022), silent = TRUE)
message("Fetching NHIS Sample Adult 2004-2022 ..."); try(fetch_nhis_sample_adult(2004:2022), silent = TRUE)
message("Fetching MEPS FYC 2019-2022 ..."); try(fetch_meps_fyc(2019:2022), silent = TRUE)

map_file <- "data-raw/fetchers/meps_event_url_map.csv"
if (file.exists(map_file)) {
  message("Fetching MEPS events via mapping CSV ...")
  try(fetch_meps_events(years = 2000:2022, events = c('rx','ob','op','er','ip'), map_file = map_file), silent = TRUE)
} else {
  message("MEPS event mapping CSV not found; skipping events.")
}

message("Fetching ACS PUMS 1-year (2014-2024) ..."); try(fetch_acs_pums(2014:2024), silent = TRUE)
message("Fetching CPS ASEC (2019-2023) ..."); try(fetch_cps_asec(2019:2023), silent = TRUE)

# Flip registry entries to local for fetched datasets
reg_path <- file.path("inst","registry","registry.csv")
if (file.exists(reg_path)) {
  reg <- try(utils::read.csv(reg_path, stringsAsFactors = FALSE), silent = TRUE)
  if (!inherits(reg, "try-error") && "id" %in% names(reg)) {
    have <- list.files(file.path("inst","extdata"), pattern = "\\.(csv|CSV)$", full.names = FALSE)
    ids_local <- sub("\\.csv$","", have)
    reg$access[reg$id %in% ids_local] <- "local"
    reg$notes[reg$id %in% ids_local] <- "local; fetched via fetchers"
    utils::write.csv(reg, reg_path, row.names = FALSE)
  }
}

# Write summary counts
sum_dir <- file.path("data-raw","summary"); if (!dir.exists(sum_dir)) dir.create(sum_dir, recursive = TRUE)
all_csv <- list.files(file.path("inst","extdata"), pattern = "\\.(csv|CSV)$", full.names = TRUE)
get_id <- function(p) sub("\\.csv$","", basename(p))
ids <- vapply(all_csv, get_id, character(1))
src <- ifelse(grepl("^nhanes_", ids), "NHANES",
         ifelse(grepl("^brfss_", ids), "BRFSS",
         ifelse(grepl("^nhis_", ids), "NHIS",
         ifelse(grepl("^meps_", ids), "MEPS",
         ifelse(grepl("^acs_pums_", ids), "ACS_PUMS",
         ifelse(grepl("^cps_asec_", ids), "CPS_ASEC","OTHER"))))))

summary <- data.frame(id = ids, source = src, stringsAsFactors = FALSE)
utils::write.csv(summary, file.path(sum_dir, "summary.csv"), row.names = FALSE)
utils::write.csv(data.frame(total = length(all_csv)), file.path(sum_dir, "summary_topline.csv"), row.names = FALSE)
message("Fetch complete. Total datasets in inst/extdata: ", length(all_csv))
