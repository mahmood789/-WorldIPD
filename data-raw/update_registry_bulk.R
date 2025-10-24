# Bulk registry expansion to target 700-1000 public IPD candidates
# Writes entries as remote_only; fetch with specific fetchers (NHANES/BRFSS/NHIS/MEPS) when ready.

reg_path <- file.path('inst','registry','registry.csv')
if (!file.exists(reg_path)) {
  dir.create(file.path('inst','registry'), recursive = TRUE, showWarnings = FALSE)
  writeLines('id,domain,source,source_url,license,citation,notes,access', reg_path)
}
reg <- utils::read.csv(reg_path, stringsAsFactors = FALSE)

add_rows <- function(df) {
  all <- unique(rbind(reg, df))
  utils::write.csv(all, reg_path, row.names = FALSE)
  message('Registry now has ', nrow(all), ' rows')
}

rows <- data.frame(id=character(),domain=character(),source=character(),source_url=character(),license=character(),citation=character(),notes=character(),access=character(), stringsAsFactors = FALSE)

# NHANES labs across cycles (register-only generic): 1999-2000 (A) to 2017-2018 (J)
cycles <- data.frame(yr=c('1999_2000','2001_2002','2003_2004','2005_2006','2007_2008','2009_2010','2011_2012','2013_2014','2015_2016','2017_2018'), suf=LETTERS[1:10], stringsAsFactors = FALSE)
labs <- c('tchol','hdl','trig','glucose','a1c','ldl','insulin','crp','ferritin','vitd')
for (i in seq_len(nrow(cycles))) {
  for (lab in labs) {
    id <- sprintf('nhanes_%s_lab_%s', cycles$yr[i], lab)
    rows[nrow(rows)+1,] <- list(id,'public_health','CDC NHANES','https://wwwn.cdc.gov/nchs/nhanes/continuousnhanes','public domain',sprintf('NHANES %s %s', cycles$yr[i], toupper(lab)),'remote_only; fetch via NHANES labs fetcher','remote_only')
  }
}

# BRFSS annual respondents 2011-2022
for (yr in 2011:2022) {
  id <- sprintf('brfss_%d', yr)
  rows[nrow(rows)+1,] <- list(id,'public_health','CDC BRFSS',sprintf('https://www.cdc.gov/brfss/annual_data/annual_%d.html', yr),'public domain',sprintf('CDC BRFSS %d', yr),'remote_only; fetch via BRFSS fetcher','remote_only')
}

# NHIS Sample Adult 2004-2022
for (yr in 2004:2022) {
  id <- sprintf('nhis_%d_samadult', yr)
  rows[nrow(rows)+1,] <- list(id,'public_health','NCHS NHIS','https://www.cdc.gov/nchs/nhis/data-questionnaires-documentation.htm','public domain',sprintf('NHIS %d Sample Adult', yr),'remote_only; fetch via NHIS fetcher','remote_only')
}

# MEPS Full-Year Consolidated 2000-2022
for (yr in 2000:2022) {
  id <- sprintf('meps_%d_fyc', yr)
  rows[nrow(rows)+1,] <- list(id,'health_economics','AHRQ MEPS','https://meps.ahrq.gov/data_stats/download_data_files.jsp','public domain',sprintf('MEPS Full-Year Consolidated %d', yr),'remote_only; fetch via MEPS fetcher','remote_only')
}

# MEPS event files (subset): RX (prescriptions), OB (office-based), OP (outpatient), ER (emergency), IP (inpatient)
events <- c('rx','ob','op','er','ip')
for (yr in 2000:2022) {
  for (ev in events) {
    id <- sprintf('meps_%d_%s', yr, ev)
    rows[nrow(rows)+1,] <- list(id,'health_economics','AHRQ MEPS','https://meps.ahrq.gov/data_stats/download_data_files.jsp','public domain',sprintf('MEPS %d %s', yr, toupper(ev)),'remote_only; fetch via MEPS fetcher','remote_only')
  }
}

# NSDUH Public Use 2002-2022 (register-only)
for (yr in 2002:2022) {
  id <- sprintf('nsduh_%d', yr)
  rows[nrow(rows)+1,] <- list(id,'public_health','SAMHSA NSDUH','https://www.samhsa.gov/data/data-we-collect/nsduh-national-survey-drug-use-and-health','public-use',sprintf('NSDUH %d Public Use', yr),'remote_only; transform to CSV offline','remote_only')
}

# CPS ASEC person-level 2000-2024
for (yr in 2000:2024) {
  id <- sprintf('cps_asec_%d', yr)
  rows[nrow(rows)+1,] <- list(id,'demographics','US Census CPS ASEC','https://www.census.gov/data/datasets/time-series/demo/cps/cps-asec.html','public domain',sprintf('CPS ASEC %d', yr),'remote_only; fetch via CPS fetcher','remote_only')
}

# ACS PUMS person-level 2005-2024
for (yr in 2005:2024) {
  id <- sprintf('acs_pums_%d', yr)
  rows[nrow(rows)+1,] <- list(id,'demographics','US Census ACS PUMS','https://www.census.gov/programs-surveys/acs/microdata.html','public domain',sprintf('ACS PUMS %d', yr),'remote_only; fetch via ACS fetcher','remote_only')
}

add_rows(rows)
