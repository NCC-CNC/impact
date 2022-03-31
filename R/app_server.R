#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  # Get inputs: ----------------------------------------------------------------

  ## Run server_load_themes.R
  eval(server_load_themes)

  ## Conservation values (rasters) ----
  user_raster <- reactive({ as.character(input$raster_selection) })

  ## PMP user shapefile upload ----
  user_pmp_upload_path <- reactive({input$upload_pmp})
  user_pmp <- read_shp(user_pmp_upload_path)

  ## Map click
  map_click <- reactive({input$ncc_map_shape_click})

  ## Disable extraction run ----
  shinyjs::disable("extractions_mod1-run_extractions")
  shinyjs::disable("report_mod1-run_report")
  shinyjs::disable("compare_tbl")
  shinyjs::disable("compare_plt")

  ## Comparison model ----
  modal_trigger <- reactive({ list(input$compare_tbl,input$compare_plt) })
  compare_tbl <- reactive({ input$compare_tbl })
  compare_plt <- reactive({ input$compare_plt })

  # Initialize leaflet map: ----------------------------------------------------

  output$ncc_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topographic") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "Streets") %>%
      fitBounds(-141.00002, 41.68132, -52.68001, 76.59341) %>%

      addSidebar(id = "map_sidebar",
                 options = list(position = "right", fit = FALSE)) %>%

      addMiniMap(tiles = providers$Esri.WorldStreetMap, toggleDisplay = T,
                 position = "bottomleft") %>%

      addMapPane("pmp_pane", zIndex = 600) %>% # Always top layer

      ## Add project mgmt. polygon ----
    addPolygons(data = PMP_sub,
                layerId = ~id, # click event id selector
                group = "Project Mgmt. Plan",
                fillColor = "#33862B",
                color = "black",
                weight = 1,
                fillOpacity = 0.7,
                label = ~htmlEscape(NAME),
                popup = PMP_popup(PMP_sub), # fct_popup.R
                options = pathOptions(pane = "pmp_pane"),
                highlightOptions = highlightOptions(weight = 3,
                                                    color = '#00ffd9')) %>%

      addLayersControl(overlayGroups = c("Project Mgmt. Plan"),
                       baseGroups = c("Streets", "Imagery", "Topographic"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = F))

  })

  # Listen for map click | pre-loaded PMPs: ------------------------------------

  observeEvent(map_click(), {

    if(is.null(map_click()$id) | map_click()$group != "Project Mgmt. Plan" ){}

    else { # If map click has an id and the group ==  Project Mgmt. Plan"

      ## PMP user selection ----
      user_pmp <- PMP_tmp %>% dplyr::filter(id == as.numeric(map_click()$id))

      ## Generate histograms ----
      shinyjs::show(id = "conditional_plots")

      property_title_SERVER(id = "property_mod2", data=user_pmp)
      output$Area <- plot_theme("Area_ha", user_pmp, goals_csv, "Area (ha)")
      output$Forest <- plot_theme("Forest", user_pmp, goals_csv, "Forest (ha)")
      output$Grassland <- plot_theme("Grassland", user_pmp, goals_csv, "Grassland (ha)")
      output$Wetland <- plot_theme("Wetland", user_pmp, goals_csv, "Wetland (ha)")
      output$River <- plot_theme("River", user_pmp, goals_csv, "River (km)")
      output$Lakes <- plot_theme("Lakes", user_pmp, goals_csv, "Lakes (ha)")

      ## Generate Table ----
      property_title_SERVER(id = "property_mod1", data=user_pmp)
      pmp_table_SERVER(id = "pmp_table_mod1",
                       data = user_pmp,
                       attributes = pmp_attributes,
                       con_values = pmp_values)
    }
  # Close map-click
  })

  # Update map with conservation theme: ----------------------------------------

  observeEvent(user_raster(),{

    if(user_raster() != F) {

      cons_pal <- colorNumeric(palette = "viridis", c(0,100))
      leafletProxy("ncc_map") %>%
        clearGroup(group= "convalue") %>%
        addMapPane("raster_map", zIndex = 400) %>%
        addTiles(urlTemplate = paste0("tiles/", user_raster(), "/{z}/{x}/{y}.png"),
                 options = pathOptions(pane = "raster_map"),
                 group = "convalue") %>%
        addLegend(position = "topleft",
                  pal = cons_pal,
                  values = c(0,100),
                  opacity = 1,
                  layerId = "cons_legend",
                  className = "info legend leaflet-control sidelegend")

    } else {

      leafletProxy("ncc_map") %>%
        clearGroup(group= "convalue") %>%
        removeControl("cons_legend")
    }

  })

  # Display user PMP / extract themes: -----------------------------------------

  ## Listen for shp upload ----
  observeEvent(user_pmp_upload_path(), {

    display_shp(user_pmp, "ncc_map")

    # Enable extract impact themes button
    shinyjs::enable("extractions_mod1-run_extractions")

  })

  ## Extract themes to user pmp, update map ----
  proxy <- leafletProxy("ncc_map")
  extracted  <- extractions_SERVER(id = "extractions_mod1", user_pmp,
                                   feat_stack, spp_stack, proxy)

  ## Extractions completed -----------------------------------------------------
  observeEvent(extracted$trigger, {
    if(extracted$flag == 1){
      shinyjs::enable("report_mod1-run_report")
      shinyjs::enable("compare_tbl")
      shinyjs::enable("compare_plt")

      ## Listen for map click
      observeEvent(map_click(), {

        if(is.null(map_click()$id) | map_click()$group != "User PMP" ){}

        else { # If map click has an id and the group ==  User PMP

          # Subset extracted sf by id ----
          user_pmp_new <- extracted$user_pmp_mean %>%
            dplyr::filter(id == as.numeric(map_click()$id))

          ## Generate plots ----
          shinyjs::show(id = "conditional_plots")
          property_title_SERVER(id = "property_mod2", user_pmp_new)
          output$Area <- plot_theme("Area_ha", user_pmp_new, goals_csv, "Area (ha)")
          output$Forest <- plot_theme("Forest", user_pmp_new, goals_csv, "Forest (ha)")
          output$Grassland <- plot_theme("Grassland", user_pmp_new, goals_csv, "Grassland (ha)")
          output$Wetland <- plot_theme("Wetland", user_pmp_new, goals_csv, "Wetland (ha)")
          output$River <- plot_theme("River", user_pmp_new, goals_csv, "River (km)")
          output$Lakes <- plot_theme("Lakes", user_pmp_new, goals_csv, "Lakes (ha)")

          ## Generate Table ----
          property_title_SERVER(id = "property_mod1", data=user_pmp_new)
          pmp_table_SERVER(id = "pmp_table_mod1",
                           data = user_pmp_new,
                           attributes = pmp_attributes,
                           con_values = pmp_values)
        }
      # Close map click
      })
    # Close extraction trigger
    }})

  # Comparison modal -----------------------------------------------------------
  comparison_SERVER(id = "compare_mod1", modal_trigger, compare_tbl,
                    compare_plt, reactive(extracted$user_pmp_mean),
                    map_click, goals_csv)

  ## Clear user pmp ----
  observeEvent(input$clear_pmp, {
    clear_shp("upload_pmp", "ncc_map", "User PMP")
    # Disable buttons
    shinyjs::disable("extractions_mod1-run_extractions")
    shinyjs::disable("report_mod1-run_report")
    shinyjs::disable("compare_tbl")
    shinyjs::disable("compare_plt")
  })

# Close app_server -------------------------------------------------------------
}
