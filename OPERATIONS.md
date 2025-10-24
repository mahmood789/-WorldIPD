# WorldIPD Operations

## Goals
- Build a large, open IPD collection with standard schema, provenance, and safe ingestion.

## Structure
- Schema: one long patient-level table per dataset (inst/extdata/<id>.csv)
- Registry: inst/registry/registry.csv (id, domain, source_url, license, citation, access)
- API: list_ipd_datasets(), get_ipd_dataset(), validate_ipd()
- Fetchers: data-raw/fetchers/ for Zenodo, GitHub, NHANES, etc.

## Privacy & Licensing
- Only ingest de-identified datasets with permissive licenses. Otherwise mark as remote_only in registry and fetch on demand.

## How to extend
- Add a row to registry for a new dataset
- Drop a standardized CSV into inst/extdata/<id>.csv
- Or write a fetcher that registers and downloads from a public source
