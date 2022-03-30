
#-------------------------------------------------------------------------------
# PMP plot and table titles
property_title_UI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "property-title",
      textOutput(outputId = ns("property"))
    )
  )
}

property_title_SERVER <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$property <- renderText({
      as.character(data$PROPERTY_N)
    })
  })
}

#-------------------------------------------------------------------------------
# PMP table outputs
pmp_table_UI <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(outputId = ns("pmp_table"))
  )
}

pmp_table_SERVER <- function(id, data, attributes, con_values) {
  moduleServer(id, function(input, output, session) {
    output$pmp_table <- renderDT({
      PMP_table(
        data = data,
        attributes = attributes,
        con_values = con_values
      )
    })
  })
}

#-------------------------------------------------------------------------------

