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

      addLayersControl(overlayGroups = c('Achievements'),
                       baseGroups = c("Topographic", "Imagery", "Streets"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = F)) %>%

      hideGroup("Achievements")

  })

  ## Display region achievement layer ----
  observeEvent(user_region(), {

    if (length(user_region()) > 0) {

    # Filter by region
    PMP_region <- PMP_tmp %>%
      dplyr::filter(stringr::str_detect(REGION, user_region()))

    # Get extent
    region_extent <- st_bbox(PMP_region)
    leafletProxy("ncc_map") %>%
      fitBounds(lng1  = region_extent[[1]], lat1 = region_extent[[2]],
                lng2 =  region_extent[[3]], lat2 =  region_extent[[4]]) %>%

    # Add achievement polygon
    clearGroup("Achievements") %>%
    showGroup("Achievements") %>%
    addPolygons(data = PMP_region,
                layerId = ~id, # click event id selector
                group = "Achievements",
                fillColor = "#33862B",
                color = "black",
                weight = 1,
                fillOpacity = 0.7,
                label = ~htmlEscape(NAME),
                popup = PMP_popup(PMP_region), # fct_popup.R
                options = pathOptions(pane = "pmp_pane"),
                highlightOptions = highlightOptions(weight = 3, color = '#00ffd9')) %>%

      addLayersControl(overlayGroups = c("Achievements"),
                       baseGroups = c("Topographic", "Imagery", "Streets"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = F))


    } else {
      # Clear achievements and zoom out to Canada
      leafletProxy("ncc_map") %>%
        clearGroup("Achievements") %>%
        hideGroup("Achievements") %>%
        fitBounds(-141.00002, 41.68132, -52.68001, 76.59341)
    }
  })

  ## Display updated user PMP ----
  observeEvent(user_pmp_upload_path(), {
    display_shp(user_pmp, "ncc_map")

    # update region selection from user_pmp attribute table
    updatePickerInput(session, "region",
                      label = "Region",
                      choices = c("BC" = "British Columbia", "AB" = "Alberta",
                                  "SK" = "Saskatchewan","MB" = "Manitoba",
                                  "ON" = "Ontario", "QC" = "Quebec", "Atlantic",
                                  "YK" = "Yukon"))

    # update property selection from user_pmp attribute table
    updatePickerInput(session, "property",
                      label = "Property",
                      choices = colnames(user_pmp()))

    # update parcel selection from user_pmp attribute table
    updatePickerInput(session, "parcel",
                      label = "Parcel",
                      choices = c(colnames(user_pmp())))

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

    # clear region selection from user_pmp
    updatePickerInput(session, "region",
                      options = pickerOptions(noneSelectedText = "NA"),
                      label = "Region",
                      choices = c(""))

    # clear property selection from user_pmp
    updatePickerInput(session, "property",
                      options = pickerOptions(noneSelectedText = "NA"),
                      label = "Property",
                      choices = c(""))

    # clear parcel selection from user_pmp
    updatePickerInput(session, "parcel",
                      options = pickerOptions(noneSelectedText = "NA"),
                      label = "Parcel",
                      choices = c(""))

  })

})
