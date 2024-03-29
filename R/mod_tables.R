#-------------------------------------------------------------------------------
# Property and parcel names
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
# Conservation table UI
pmp_table_UI <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(outputId = ns("pmp_table"))
  )
}

# Conservation table SERVER
pmp_table_SERVER <- function(id, data, attributes, con_values, property, parcel,
                             region, goals_csv, dt_proxy = NULL, modal = F) {
  moduleServer(id, function(input, output, session) {

    # Render empty table ----
    if (modal == F & is.null(dt_proxy)) {
      output$pmp_table <- renderDT({
        pmp_empty_table(attributes = attributes)
      })
      # Populate table even when Tbl. tab is not selected
      outputOptions(output, "pmp_table", suspendWhenHidden = FALSE)
    }

    # Update table with pulled values ----
    if (modal == F & !is.null(dt_proxy)) {
      DT::replaceData(
        proxy = dt_proxy,
        rownames = FALSE,
        PMP_table_single_property(
          data = data,
          attributes = attributes,
          con_values = con_values,
          property = property,
          parcel = parcel
         )
        )
      }

    # Render modal table ----
    if (modal == T & is.null(dt_proxy)) {
      output$pmp_table <- renderDT({
        PMP_table(
          data = data,
          attributes = attributes,
          con_values = con_values,
          property = property,
          parcel = parcel,
          region = region,
          goals_csv = goals_csv)
      })
    }
  })
}

#-------------------------------------------------------------------------------
# Engagement table UI
eng_table_UI <- function(id) {
  ns <- NS(id)
  tagList(
    DTOutput(outputId = ns("eng_table"))
  )
}

# Engagement table SERVER
eng_table_SERVER <- function(id, oid = NULL, nl_ncc = NULL, dt_proxy = NULL) {
  moduleServer(id, function(input, output, session) {

    # Render empty native lands table ----
    if (is.null(dt_proxy)) {
      output$eng_table <- renderDT({
        eng_empty_table()
      })
      # Populate table even when ENG. tab are not selected
      outputOptions(output, "eng_table", suspendWhenHidden = FALSE)
    } else {
      # Build native lands table ----
      DT::replaceData(
        proxy = dt_proxy,
        rownames = FALSE,
        eng_table(
          oid = oid,
          nl_ncc = nl_ncc))
      }
  })
}

