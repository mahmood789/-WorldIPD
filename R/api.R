#' List available IPD datasets (registered)
#' @return data.frame of registry entries
#' @export
list_ipd_datasets <- function(){
  rp <- system.file('registry','registry.csv', package = utils::packageName(), mustWork = FALSE)
  if (!nzchar(rp)) rp <- file.path('inst','registry','registry.csv')
  if (!file.exists(rp)) return(utils::read.csv(text = 'id,domain,source,source_url,license,citation,notes,access', stringsAsFactors = FALSE))
  utils::read.csv(rp, stringsAsFactors = FALSE)
}

#' Get an IPD dataset by id
#' @param id character dataset id
#' @return data.frame of patient-level records
#' @export
get_ipd_dataset <- function(id){
  stopifnot(is.character(id), length(id) == 1)
  p <- system.file('extdata', paste0(id, '.csv'), package = utils::packageName(), mustWork = FALSE)
  if (!nzchar(p)) p <- file.path('inst','extdata', paste0(id, '.csv'))
  if (!file.exists(p)) stop('Dataset not found in inst/extdata: ', id)
  utils::read.csv(p, check.names = FALSE, stringsAsFactors = FALSE)
}

#' Validate IPD dataset against minimal schema
#' @param df data.frame
#' @return list(ok=logical, issues=character)
#' @export
validate_ipd <- function(df){
  issues <- character();
  if (!is.data.frame(df)) return(list(ok = FALSE, issues = 'not a data.frame'))
  req <- c('patient_id','study_id')
  miss <- setdiff(req, names(df))
  if (length(miss)) issues <- c(issues, paste('Missing:', paste(miss, collapse=',')))
  if ('patient_id' %in% names(df)) {
    if (any(is.na(df$patient_id))) issues <- c(issues, 'NA patient_id present')
  }
  list(ok = length(issues) == 0, issues = issues)
}

#' Launch the WorldIPD Shiny browser
#' @export
launch_worldipd_browser <- function(){
  app_dir <- if (nzchar(system.file('shiny', package = utils::packageName()))) {
    system.file('shiny', package = utils::packageName())
  } else {
    file.path('inst','shiny')
  }
  if (!dir.exists(app_dir)) stop('Shiny app not found at ', app_dir)
  shiny::runApp(app_dir, launch.browser = TRUE)
}
