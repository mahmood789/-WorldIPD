# Simple WorldIPD browser (Shiny)

suppressWarnings(suppressMessages({
  library(shiny)
  library(utils)
}))

get_registry <- function(){
  rp <- file.path('inst','registry','registry.csv')
  if (file.exists(rp)) tryCatch(read.csv(rp, stringsAsFactors = FALSE), error=function(e) NULL) else NULL
}

get_local_datasets <- function(){
  files <- list.files(file.path('inst','extdata'), pattern = '\\.(csv|CSV)$', full.names = TRUE)
  ids <- sub('\\.csv$','', basename(files))
  src <- ifelse(grepl('^nhanes_', ids), 'NHANES',
           ifelse(grepl('^brfss_', ids), 'BRFSS',
           ifelse(grepl('^nhis_', ids), 'NHIS',
           ifelse(grepl('^meps_', ids), 'MEPS',
           ifelse(grepl('^acs_pums_', ids), 'ACS_PUMS',
           ifelse(grepl('^cps_asec_', ids), 'CPS_ASEC','OTHER'))))))
  data.frame(id = ids, file = files, source = src, stringsAsFactors = FALSE)
}

ui <- fluidPage(
  titlePanel('WorldIPD Browser'),
  fluidRow(
    column(3, wellPanel(
      h4('Summary'),
      verbatimTextOutput('counts'),
      selectInput('dataset', 'Select dataset', choices = NULL),
      actionButton('refresh', 'Refresh')
    )),
    column(9, tabsetPanel(
      tabPanel('Preview', tableOutput('preview')),
      tabPanel('Registry', tableOutput('registry'))
    ))
  )
)

server <- function(input, output, session){
  reg <- reactiveVal(get_registry())
  local <- reactiveVal(get_local_datasets())

  observe({
    ds <- local()
    updateSelectInput(session, 'dataset', choices = ds$id)
  })

  output$counts <- renderText({
    ds <- local(); r <- reg()
    paste0(
      'Local datasets: ', nrow(ds), '\n',
      'By source: ', paste(tapply(ds$id, ds$source, length), names(tapply(ds$id, ds$source, length)), sep=' x ', collapse='; '), '\n',
      'Registry rows: ', if (is.null(r)) 0 else nrow(r)
    )
  })

  output$registry <- renderTable({ reg() })

  output$preview <- renderTable({
    req(input$dataset)
    ds <- local(); row <- ds[ds$id == input$dataset, , drop = FALSE]
    if (!nrow(row)) return(NULL)
    tryCatch({
      head(read.csv(row$file, check.names = FALSE, stringsAsFactors = FALSE), 20)
    }, error = function(e) NULL)
  })

  observeEvent(input$refresh, {
    reg(get_registry()); local(get_local_datasets())
  })
}

shinyApp(ui, server)
