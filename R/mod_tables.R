
#-------------------------------------------------------------------------------
# PMP plot and table titles
property_title_UI <- function(id) {
  ns <- NS(id)
  tagList(
    tags$div(
      class = "property-title",
      textOutput(outputId = ns("property"))
    ),
    tags$div(
      class = "parcel-title",
      textOutput(outputId = ns("parcel"))
    )
  )
}

property_title_SERVER <- function(id, data, property_field, parcel_field) {
  moduleServer(id, function(input, output, session) {
      output$property <- renderText({
        as.character(data[[property_field]])
    })

      output$parcel <- renderText({
        as.character(data[[parcel_field]])
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

pmp_table_SERVER <- function(id, data, attributes, con_values, property, parcel) {
  moduleServer(id, function(input, output, session) {
    output$pmp_table <- renderDT({

      PMP_table(
        data = data,
        attributes = attributes,
        con_values = con_values,
        property = property,
        parcel = parcel
      )
    })
  })
}

#-------------------------------------------------------------------------------

