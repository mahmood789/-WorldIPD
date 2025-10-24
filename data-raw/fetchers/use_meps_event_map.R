# Use a MEPS event mapping CSV to fetch events across years
# Edit a copy of data-raw/fetchers/meps_event_url_map_template.csv to include rows:
# year,event,url
# 2010,rx,https://meps.ahrq.gov/data_files/pufs/h###a/h###axpt.zip

source('data-raw/fetchers/fetch_meps_events.R')
map_file <- 'data-raw/fetchers/meps_event_url_map.csv'  # create this file from the template and fill URLs
if (!file.exists(map_file)) stop('Create ', map_file, ' from the template and add (year,event,url) rows.')
fetch_meps_events(years = 2000:2022, events = c('rx','ob','op','er','ip'), map_file = map_file)
