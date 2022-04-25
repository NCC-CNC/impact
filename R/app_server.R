#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

#===============================================================================
  # Set inputs -----------------------------------------------------------------

  ## Conservation themes (rasters) ----
  user_theme <- reactive({ as.character(input$theme_selection) })

  ## Map click
  map_click <- reactive({input$ncc_map_shape_click})

  ## PMP user shapefile upload ----
  user_pmp_upload_path <- reactive({input$upload_pmp})
  user_pmp <- read_shp(user_pmp_upload_path)

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

  ## Initialize leaflet map: ----
  eval(server_initmap)

  ## Listen for map click and render table/plots  ----
  eval(server_mapclick)

  ## Update map with conservation theme: ----
  eval(server_showtheme)

  ## Read-in theme rasters ----
  eval(server_load_themes)

#===============================================================================
  # Extraction workflow --------------------------------------------------------

  ## Extract themes to uploaded pmps and update ncc_map ----
  proxy <- leafletProxy("ncc_map")
  extracted  <- extractions_SERVER(id = "extractions_mod1", user_pmp, feat_stack,
                                   spp_stack, proxy)

  ## Extractions successfully completed ----
  observeEvent(extracted$trigger, {
    if(extracted$flag == 1){
      shinyjs::enable("report_mod1-run_report")
      shinyjs::enable("compare_tbl")
      shinyjs::enable("compare_plt")
    }
  })

  ## Comparison modal ----
  comparison_SERVER(id = "compare_mod1", modal_trigger, compare_tbl,
                    compare_plt, reactive(extracted$user_pmp_mean),
                    map_click, goals_csv)

#===============================================================================
# Close app_server -------------------------------------------------------------
}
