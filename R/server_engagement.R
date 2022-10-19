server_engagement <- quote ({

  # Listen for native lands selection ----
  observeEvent(input$native_lands, {

    req(input$native_lands)

    # Native lands layer
    native_land_geojson <- reactive({
      switch(as.character(input$native_lands),
        "Off" = "off",
         "Territories" = file.path(data_path, "native_lands", "native_lands_territories.geojson"),
         "Languages" = file.path(data_path, "native_lands", "native_lands_languages.geojson"),
         "Treaties" = file.path(data_path, "native_lands", "native_lands_treaties.geojson"))
      })

    # Add native land layer to map
    if (input$native_lands != "Off") {

      native_land_layer <- geojsonsf::geojson_sf(native_land_geojson())
      # sort polygons smallest to largest
      native_land_layer <- dplyr::arrange(native_land_layer, -area)

      leafletProxy("ncc_map") %>%
        clearGroup(group = "Native Lands") %>%
        addPolygons(data = native_land_layer,
                    fillColor = native_land_layer$color,
                    color = "black",
                    weight = 1,
                    fillOpacity = 0.3,
                    group = "Native Lands",
                    label = lapply(native_land_layer$Name, htmltools::HTML),
                    highlightOptions =
                      highlightOptions(weight = 10, color = native_land_layer$color)
                    )
    } else {
      # Clear native land layers when off
      leafletProxy("ncc_map") %>%
        clearGroup(group = "Native Lands")

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
          addPolygons(data = reserve_groups[[input$reserves]]$sf,
                      group = reserve_groups[[input$reserves]]$group,
                      fillColor = "#ffff33",
                      color = "black",
                      weight = 1,
                      fillOpacity = 0.5,
                      label = ~NAME1,
                      highlightOptions =
                        highlightOptions(weight = 5, color = "#ffff33")) %>%
          showGroup(reserve_groups[[input$reserves]]$group)

    } else {

      # Clear all reserves and then show the reserve that is cached
      leafletProxy("ncc_map") %>%
        hideGroup(reserve_names) %>%
        showGroup(reserve_groups[[input$reserves]]$group)
    }
  } else {

    # Clear all reserves
    leafletProxy("ncc_map") %>%
      hideGroup(reserve_names) %>%
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
