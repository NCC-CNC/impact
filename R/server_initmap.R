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
                 options = list(position = "right", fit = FALSE)) %>%

       addMiniMap(toggleDisplay = T,
                  tiles = providers$Esri.WorldStreetMap,
                 position = "bottomleft") %>%

      addMapPane("pmp_pane", zIndex = 600) %>% # Always top layer

      addLayersControl(overlayGroups = c('British Columbia', "Alberta",
                        "Saskatchewan","Manitoba", "Ontario", "Quebec",
                        "Atlantic","Yukon"),
                       baseGroups = c("Topographic", "Imagery", "Streets"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = T)) %>%

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
          $('.leaflet-control-layers-overlays').prepend('<label style=\"text-align:center\">Achievments</label>');
          $('.leaflet-control-layers-list').prepend('<label style=\"text-align:center\">Basemaps</label>');
        }
    ") %>%

      # Leaflet spinner for addPolgygon ...
      # https://davidruvolo51.github.io/shinytutorials/tutorials/leaflet-loading-screens/
      htmlwidgets::onRender(., "
                function(el, x, data) {
                    // select map, loader, button
                    var m = this;
                    const elem = document.getElementById('leafletBusy');
                    const reserves = document.querySelectorAll('#reserves input');
                    // when map is rendered, display loading
                    // adjust delay as needed
                    m.whenReady(function() {
                        elem.classList.remove('visually-hidden');
                        setTimeout(function() {
                            elem.classList.add('visually-hidden');
                        }, 0)
                    });
                    // click event on radio button node list
                    for (var i = 0; i < reserves.length; i++) {
                    reserves[i].addEventListener('change', function(event) {
                        // show loading element
                        elem.classList.remove('visually-hidden');
                        (new Promise(function(resolve, reject) {
                            // leaflet event: layeradd
                            m.addEventListener('layeradd', function(event) {
                                console.log(event.type)
                                // resolve after a few seconds to ensure all
                                // elements rendered (adjust as needed)
                                // time is in milliseconds
                                setTimeout(function() {
                                    resolve('done');
                                }, 0)
                            })
                        })).then(function(response) {
                            // resolve: hide loading screen
                            console.log('done');
                            elem.classList.add('visually-hidden');
                        }).catch(function(error) {
                            // throw errors
                            console.error(error);
                        });
                    });
                    };
                }") %>%

      # Turn off all group layers
      hideGroup("British Columbia") %>%
      hideGroup("Alberta") %>%
      hideGroup("Saskatchewan") %>%
      hideGroup("Manitoba") %>%
      hideGroup("Ontario") %>%
      hideGroup("Quebec") %>%
      hideGroup("Atlantic") %>%
      hideGroup("Yukon")

  })

  # Load achievement polygons by region when selected in layer controls.
  # Only load once.
  observeEvent(input$ncc_map_groups, {

    # remove base groups
    layer_on <- input$ncc_map_groups[!(input$ncc_map_groups %in%
      c("Topographic","Imagery","Streets", "convalue", "User PMP",
        "Native Lands", "First Nation Locations", "Tribal Councils",
        "Inuit Communities", "BC Reserves", "AB Reserves", "SK Reserves",
        "MB Reserves", "ON Reserves", "QC Reserves", "AT Reserves",
        "YK Reserves", "NWT Reserves", "NU Reserves"))]

    # Check that at least 1 of the overlay groups is toggled on
    if (length(layer_on) > 0) {

      # update cached list by adding
      for(i in layer_on) {
        cached[[i]] <<-  cached[[i]] + 1
      }

      # add polygon
      for(name in  names(cached)){

        if (cached[[name]] == 1) {
          data <- achievements[name][[1]]
          leafletProxy("ncc_map") %>%
            addPolygons(data = data,
                        group = name,
                        layerId = ~id, # click event id selector
                        label = ~htmlEscape(NAME),
                        popup = PMP_popup(data), # fct_popup.R
                        fillColor = "#33862B",
                        color = "black",
                        weight = 1,
                        fillOpacity = 0.7,
                        options = pathOptions(pane = "pmp_pane"),
                        highlightOptions =
                          highlightOptions(weight = 3, color = '#00ffd9'))
          }
        }
     }
    })

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
