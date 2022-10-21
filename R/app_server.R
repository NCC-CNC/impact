#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

#===============================================================================
  # Set inputs -----------------------------------------------------------------

  # Hide side bar
  shinyjs::hide("map_sidebar")

  ## Conservation themes (rasters) ----
  user_theme <- reactive({ as.character(input$theme_selection) })

  # ## Region achievements ----
  # user_region <- reactive({ as.character(input$Id083) })

  ## Map click
  map_click <- reactive({input$ncc_map_shape_click})

  ## PMP user shapefile upload ----
  user_pmp_upload_path <- reactive({input$upload_pmp})
  user_pmp <- read_shp(user_pmp_upload_path)

  ## PMP user region
  user_pmp_region <- reactive({input$region})

  ## PMP user property field
  user_pmp_property <- reactive({input$property})

  ## PMP user parcel field
  user_pmp_parcel <- reactive({input$parcel})

  ## Comparison buttons ----
  modal_trigger <- reactive({ list(input$compare_tbl,input$compare_plt) })
  compare_tbl <- reactive({ input$compare_tbl })
  compare_plt <- reactive({ input$compare_plt })

  ## Disable buttons ----
  shinyjs::disable("extractions_mod1-run_extractions")
  shinyjs::disable("report_mod1-run_report")
  shinyjs::disable("compare_tbl")
  shinyjs::disable("compare_plt")

  ## Tool tips ----
  addTooltip(session, id = "map_sidebar", title = "Open / Close map sidebar",
             placement = "top", trigger = "hover")

#===============================================================================
  # Mapping workflow -----------------------------------------------------------

  ## Initialize data structure: ----
  eval(server_data_structure)

  ## Initialize leaflet map: ----
  eval(server_initmap)

  ## Listen for map click and render table/plots  ----
  eval(server_mapclick)

  ## Engagement layers  ----
  eval(server_engagement)

  ## Update map with conservation theme: ----
  eval(server_showtheme)

#===============================================================================
  # Extraction workflow --------------------------------------------------------

  ## Extract themes to uploaded pmps and update ncc_map ----
  proxy <- leafletProxy("ncc_map")
  extracted  <- extractions_SERVER(id = "extractions_mod1",
                                   user_pmp,
                                   proxy,
                                   user_pmp_region)

  ## Extractions successfully completed ----
  observeEvent(extracted$trigger, {
    if(extracted$flag == 1){
      shinyjs::enable("report_mod1-run_report")
      shinyjs::enable("compare_tbl")
      shinyjs::enable("compare_plt")
    }
  })

  ## Comparison modal ----
  comparison_SERVER(id = "compare_mod1",
                    modal_trigger,
                    compare_tbl,
                    compare_plt,
                    reactive(extracted$user_pmp_mean),
                    map_click,
                    goals_csv,
                    user_pmp_property,
                    user_pmp_parcel)

#===============================================================================
  # Help --------------------------------------------------------
  ## properties
  observeEvent(input$overview_switch, {
    if (input$overview_switch) {
      shinyjs::show("overview_txt")
    } else {
      shinyjs::hide("overview_txt")
    }
  })

  ## table
  observeEvent(input$table_switch, {
    if (input$table_switch) {
      shinyjs::show("table_txt")
    } else {
      shinyjs::hide("table_txt")
    }
  })

  ## plot
  observeEvent(input$plot_switch, {
    if (input$plot_switch) {
      shinyjs::show("plot_txt")
    } else {
      shinyjs::hide("plot_txt")
    }
  })

  ## plot
  observeEvent(input$indigenous_switch, {
    if (input$indigenous_switch) {
      shinyjs::show("indigenous_txt")
    } else {
      shinyjs::hide("indigenous_txt")
    }
  })

#===============================================================================
# Close app_server -------------------------------------------------------------
}
