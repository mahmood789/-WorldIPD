reg <- read.csv('inst/registry/registry.csv', stringsAsFactors = FALSE)
add <- data.frame(
  id = c('brfss_2019','brfss_2020','brfss_2021','brfss_2022',
         'nhis_2019_samadult','nhis_2020_samadult','nhis_2021_samadult','nhis_2022_samadult'),
  domain = 'public_health',
  source = c(rep('CDC BRFSS',4), rep('NCHS NHIS',4)),
  source_url = c('https://www.cdc.gov/brfss/annual_data/annual_2019.html',
                 'https://www.cdc.gov/brfss/annual_data/annual_2020.html',
                 'https://www.cdc.gov/brfss/annual_data/annual_2021.html',
                 'https://www.cdc.gov/brfss/annual_data/annual_2022.html',
                 rep('https://www.cdc.gov/nchs/nhis/data-questionnaires-documentation.htm',4)),
  license = 'public domain',
  citation = c(rep('CDC BRFSS Annual',4), rep('NCHS NHIS Sample Adult',4)),
  notes = rep('remote_only; downloadable via fetchers', 8),
  access = 'remote_only',
  stringsAsFactors = FALSE
)
reg2 <- unique(rbind(reg, add))
write.csv(reg2, 'inst/registry/registry.csv', row.names = FALSE)
message('Updated registry with BRFSS/NHIS entries')
