server_initmap <- quote ({

  # Initialize leaflet map: ----------------------------------------------------
  output$ncc_map <- renderLeaflet({
    leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
      addTiles() %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "Imagery") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "Streets") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "Topographic") %>%
      fitBounds(-141.00002, 41.68132, -52.68001, 76.59341) %>%

      addSidebar(id = "map_sidebar",
                 options = list(position = "right")) %>%

      addMapPane("pmp_pane", zIndex = 600) %>% # Always top layer

       addMiniMap(toggleDisplay = TRUE,
                  tiles = providers$Esri.WorldStreetMap,
                  position = "bottomleft",
                  minimized = TRUE,) %>%

      addLayersControl(baseGroups = c("Topographic", "Imagery", "Streets"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = TRUE)) %>%

      # Get mouse over coordinates
      htmlwidgets::onRender(
        "function(el,x){
                    this.on('mousemove', function(e) {
                        var lat = e.latlng.lat;
                        var lng = e.latlng.lng;
                        var coord = [lat, lng];
                        Shiny.onInputChange('hover_coordinates', coord)
                    });
                    this.on('mouseout', function(e) {
                        Shiny.onInputChange('hover_coordinates', null)
                    })
                }"
      ) %>%

      # Style layer control titles
      htmlwidgets::onRender("
        function() {
          $('.leaflet-control-layers-list').prepend('<label style=\"text-align:center\">Basemaps</label>');
        }
    ") %>%

      # Leaflet spinner for addPolygon
      # https://davidruvolo51.github.io/shinytutorials/tutorials/leaflet-loading-screens/
      htmlwidgets::onRender(., addPolygon_spinner_ugly_js)

  })

  # Listen for NCC regions (accomplishment / parcel) selection
  observeEvent(input$ncc_regions, {

    # Hide NCC parcels if nothing is checked
    if (length(input$ncc_regions) == 0) {
      leafletProxy("ncc_map") %>%
        hideGroup(c("AB", "BC", "SK", "MB", "ON", "QC", "AT", "YK")) %>%
        # Add ghost point to turn off css spinner
        addCircleMarkers(lng = -96.8165,
                         lat = 49.7713,
                         radius = 0,
                         fillOpacity = 0,
                         stroke = FALSE,
                         weight = 0)

    } else {

      # Map NCC parcel
      for (parcel in input$ncc_regions) {
        # Subset and display parcel for first time selection
        if (is.null(ncc_parcels[[parcel]]$sf)) {
          ncc_parcels[[parcel]]$sf <<- dplyr::filter(PMP_tmp, REGION == ncc_parcels[[parcel]]$region)
          leafletProxy("ncc_map") %>%
            addPolygons(data = ncc_parcels[[parcel]]$sf,
                        group = ncc_parcels[[parcel]]$group,
                        layerId = ~id, # click event id selector
                        label = ~htmlEscape(NAME),
                        labelOptions = labelOptions(
                          style = list(
                            "z-index" = "9999",
                            "font-size" = "12px",
                            "border-color" = "rgba(0,0,0,0.5)"
                          )),
                        popup = PMP_popup(ncc_parcels[[parcel]]$sf), # fct_popup.R
                        fillColor = "#33862B",
                        color = "black",
                        weight = 1,
                        fillOpacity = 0.7,
                        options = pathOptions(pane = "pmp_pane"),
                        highlightOptions =
                          highlightOptions(weight = 3, color = '#00ffd9')) %>%
            showGroup(ncc_parcels[[parcel]]$group)

        } else {
         # Clear then show cached groups
          ncc_groups <- c("BC", "AB", "SK", "MB", "ON", "QC", "AT", "YK")
          ncc_clear <- ncc_groups[!(ncc_groups %in% input$ncc_regions)]
          ncc_show <- ncc_groups[(ncc_groups %in% input$ncc_regions)]
          leafletProxy("ncc_map") %>%
            hideGroup(ncc_clear) %>%
            showGroup(ncc_show) %>%
            # Add ghost point to turn off css spinner
            addCircleMarkers(lng = -96.8165,
                             lat = 49.7713,
                             radius = 0,
                             fillOpacity = 0,
                             stroke = FALSE,
                             weight = 0)
        }
      }
    }
  }, ignoreNULL = FALSE)


  ## Display updated user PMP ----
  observeEvent(user_pmp_upload_path(), {

    display_shp(user_pmp, "ncc_map")

    # Fields in attribute table
    remove <- c("geometry", "id")
    user_pmp_fields <- setdiff(colnames(user_pmp()), remove)

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
                      choices = user_pmp_fields)

    # update parcel selection from user_pmp attribute table
    updatePickerInput(session, "parcel",
                      label = "Parcel",
                      choices = user_pmp_fields)

    shinyjs::enable("extractions_mod1-run_extractions")

  })

  ## Clear user PMP ----
  observeEvent(input$clear_pmp, {
    clear_shp("upload_pmp", "ncc_map", "User PMP")
    # Disable buttons
    shinyjs::disable("extractions_mod1-run_extractions")
    shinyjs::disable("download_mod1-download")
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

  shinyjs::show("map_sidebar")

})
