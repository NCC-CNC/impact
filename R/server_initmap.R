server_initmap <- quote ({

  # Initialize leaflet map: ----------------------------------------------------
  output$ncc_map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "Streets") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topographic") %>%
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
                       baseGroups = c("Topographic", "Imagery", "Streets"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = F))

  })

  ## Display updated user PMP ----
  observeEvent(user_pmp_upload_path(), {
    display_shp(user_pmp, "ncc_map")
    shinyjs::enable("extractions_mod1-run_extractions")
  })

  ## Clear user PMP ----
  observeEvent(input$clear_pmp, {
    clear_shp("upload_pmp", "ncc_map", "User PMP")
    # Disable buttons
    shinyjs::disable("extractions_mod1-run_extractions")
    shinyjs::disable("report_mod1-run_report")
    shinyjs::disable("compare_tbl")
    shinyjs::disable("compare_plt")
  })

})
