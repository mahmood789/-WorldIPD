# Crawl Zenodo for IPD-like datasets and register them (and optionally download)
# Requires: httr, jsonlite

search_terms <- c('"individual participant data"', '"individual patient data"', 'IPD dataset')
max_per_term <- 50

# Implement logic: call Zenodo API, filter by file extensions, write to inst/registry/registry.csv
