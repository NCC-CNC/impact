# PMP plot and table titles
report_UI <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    fluidRow(column(8, offset = 2, align = "center",
      actionButton(inputId = ns("run_report"), label = "Generate Report", 
      icon = icon("download"), width = "100%")))
  )
}

report_SERVER <- function(id, data) {
  moduleServer(id, function(input, output, session) {

  })
}