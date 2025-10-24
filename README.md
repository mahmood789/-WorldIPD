# WorldIPD

A standard scaffolding for an open Individual Participant Data (IPD) hub.

- Standard schema for patient-level datasets (one long table per dataset)
- Registry of sources (provenance-first): inst/registry/registry.csv
- Fetchers for public sources (Zenodo/GitHub/NHANES) under data-raw/fetchers/
- Validators and a simple API to list and load datasets

## Schema (recommended columns)
- `dataset_id`, `patient_id`, `study_id`, `arm_id`
- Time-to-event: `time`, `event` (0/1), or outcome columns for other endpoints
- Covariates: e.g., `age`, `sex`, `baseline_*` (preserved as-is)
- Provenance: `source_url`, `license`, `citation`

## Quick Start
```r
# List registered datasets
WorldIPD::list_ipd_datasets()

# Load a dataset (from inst/extdata)
df <- WorldIPD::get_ipd_dataset('example_ipd')
str(df)

# Validate schema
WorldIPD::validate_ipd(df)
```

## Fetching public IPD
- Use `data-raw/fetchers/fetch_zenodo_ipd.R` to crawl Zenodo for candidate CSV/TSV/XLSX/RDS files that look like IPD (requires httr/jsonlite). Writes to the registry and optionally downloads to inst/extdata.
- Use `data-raw/fetchers/fetch_github_ipd.R` to crawl GitHub repos (requires a GITHUB_TOKEN to avoid rate limits) and register/download candidates.
- Use `data-raw/fetchers/fetch_nhanes.R` to fetch NHANES cores (public patient-level data) as working examples.

## Notes on privacy
- Do not include direct identifiers. Ensure all datasets are de-identified and permissibly licensed. When in doubt, keep entries as `remote_only` in the registry and fetch on demand.
