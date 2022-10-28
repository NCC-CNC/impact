server_engagement <- quote ({

  # Listen for native lands selection ----
  observeEvent(input$native_lands, {

    req(input$native_lands)

    # Add native land layer to map
    if (input$native_lands != "Off") {
      # Read-in data for first time selection
      if (is.null(native_land_groups[[input$native_lands]]$sf)) {
        # Read-in native land polygon
        native_land_groups[[input$native_lands]]$sf <<-
          geojsonsf::geojson_sf(native_land_groups[[input$native_lands]]$path) %>%
            # sort polygons smallest to largest
            dplyr::arrange(-area)

        # Add to map
        leafletProxy("ncc_map") %>%
          hideGroup(native_land_names) %>%
          addPolygons(data = native_land_groups[[input$native_lands]]$sf,
                      fillColor = native_land_groups[[input$native_lands]]$sf$color,
                      color = "black",
                      weight = 1,
                      fillOpacity = 0.3,
                      group = native_land_groups[[input$native_lands]]$group,
                      label = lapply(native_land_groups[[input$native_lands]]$sf$Name, htmltools::HTML),
                      labelOptions = labelOptions(
                        style = list(
                          "z-index" = "9999",
                          "font-family" = "serif",
                          "font-size" = "12px",
                          "border-color" = "rgba(0,0,0,0.5)"
                        )),
                      highlightOptions =
                        highlightOptions(weight = 10, color = native_land_groups[[input$native_lands]]$sf$color)) %>%
          showGroup(native_land_groups[[input$native_lands]]$group)

      } else {
        # Hide all native land and then show the cached native land
        leafletProxy("ncc_map") %>%
          hideGroup(native_land_names) %>%
          showGroup(native_land_groups[[input$native_lands]]$group)
      }
    } else {
      # Hide all native lands
      leafletProxy("ncc_map") %>%
        hideGroup(native_land_names) %>%
        # Add ghost point to turn off css spinner
        addCircleMarkers(lng = -96.8165,
                         lat = 49.7713,
                         radius = 0,
                         fillOpacity = 0,
                         stroke = FALSE,
                         weight = 0)
      }
  })

  # Listen for First Nation reserve selection ----
  observeEvent(input$reserves, {

    req(input$reserves)

    # Add First Nation reserves to map
    if (input$reserves != "Off") {

      # Follows data structure built in app_global.R
      if (is.null(reserve_groups[[input$reserves]]$sf)) {

        # Read-in reserve polygon
        reserve_groups[[input$reserves]]$sf <<- sf::read_sf(reserve_groups[[input$reserves]]$path)

        # Map reserve (only addPolygons once for province)
        leafletProxy("ncc_map") %>%
          hideGroup(reserve_names) %>%
          addMapPane("fnr_pane", zIndex = 601) %>%
          addPolygons(data = reserve_groups[[input$reserves]]$sf,
                      group = reserve_groups[[input$reserves]]$group,
                      fillColor = "#ffff33",
                      color = "black",
                      weight = 1,
                      fillOpacity = 0.5,
                      label = ~NAME1,
                      labelOptions = labelOptions(
                                      style = list(
                                        "z-index" = "9999",
                                        "font-family" = "serif",
                                        "font-size" = "12px",
                                        "border-color" = "rgba(0,0,0,0.5)"
                                        )),
                      options = pathOptions(pane = "fnr_pane"),
                      highlightOptions =
                        highlightOptions(weight = 5, color = "#ffff33")) %>%
          showGroup(reserve_groups[[input$reserves]]$group)

    } else {

      # Clear all reserves and then show the reserve that is cached
      leafletProxy("ncc_map") %>%
        clearGroup(reserve_names) %>%
        showGroup(reserve_groups[[input$reserves]]$group)
    }
  } else {

    # Clear all reserves
    leafletProxy("ncc_map") %>%
      clearGroup(reserve_names) %>%
    # Add ghost point to turn off css spinner
      addCircleMarkers(lng = -96.8165,
                       lat = 49.7713,
                       radius = 0,
                       fillOpacity = 0,
                       stroke = FALSE,
                       weight = 0)
    }
  # Close First Nation reserve observeEvent
  })

  # Listen for First Nation points selection ----
  observeEvent(input$first_nation, {

    # Clear First Nation point
    if (length(input$first_nation) == 0) {
      leafletProxy("ncc_map") %>%
        clearGroup("First Nation Locations") %>%
        clearGroup("Tribal Councils") %>%
        clearGroup("Inuit Communities") %>%
        clearGroup("First Nation Reserves")
    } else {
      fn_groups <- c("First Nation Locations", "Tribal Councils", "Inuit Communities")
      fn_clear <- fn_groups[!(fn_groups %in% input$first_nation)]
      for (clear in fn_clear) {
        leafletProxy("ncc_map") %>%
          clearGroup(fn_clear)
      }
    }

    # Add First Nation points ----
    for (fn in input$first_nation) {

      if (fn == "First Nation Locations") {
        leafletProxy("ncc_map", data = fn_points) %>%
          addMapPane("fnl", zIndex = 700) %>%
          addCircleMarkers(label = ~BAND_NAME,
                           labelOptions = labelOptions(
                             style = list(
                               "z-index" = "9999",
                               "font-family" = "serif",
                               "font-size" = "12px",
                               "border-color" = "rgba(0,0,0,0.5)"
                             )),
                           group = "First Nation Locations",
                           radius = 4,
                           color = "Black",
                           fillOpacity = 1,
                           weight = 1,
                           fillColor = "#ff7f00",
                           options = pathOptions(pane = "fnl"))

      } else if (fn == "Tribal Councils") {
        leafletProxy("ncc_map", data = tc_points) %>%
          addMapPane("tc", zIndex = 699) %>%
          addCircleMarkers(label = ~TC_NAME,
                           labelOptions = labelOptions(
                             style = list(
                               "z-index" = "9999",
                               "font-family" = "serif",
                               "font-size" = "12px",
                               "border-color" = "rgba(0,0,0,0.5)"
                             )),
                           group = "Tribal Councils",
                           radius = 7,
                           color = "Black",
                           fillOpacity = 1,
                           weight = 1,
                           fillColor = "#377eb8",
                           options = pathOptions(pane = "tc"))

      } else if (fn == "Inuit Communities") {
        leafletProxy("ncc_map", data = ic_points) %>%
          addMapPane("ic", zIndex = 701) %>%
          addCircleMarkers(label = ~NAME,
                           labelOptions = labelOptions(
                             style = list(
                               "z-index" = "9999",
                               "font-family" = "serif",
                               "font-size" = "12px",
                               "border-color" = "rgba(0,0,0,0.5)"
                             )),
                           group = "Inuit Communities",
                           radius = 4,
                           color = "Black",
                           fillOpacity = 1,
                           weight = 1,
                           fillColor = "#984ea3",
                           options = pathOptions(pane = "ic"))
        }
      # Close First Nation points for loop
      }
    # Close First Nation points observeEvent
    }, ignoreNULL = FALSE) # get status of buttons when app inits
# Close quote
})
