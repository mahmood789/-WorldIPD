# Crawl GitHub repos for IPD-like datasets and register them (and optionally download)
# Requires: httr, jsonlite, GITHUB_TOKEN for rate limits

queries <- c('"individual patient data" in:readme', 'IPD dataset in:readme')
# Implement logic: search GitHub API, enumerate repo trees, filter CSV/TSV/XLSX/RDS, write to registry
