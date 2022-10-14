server_engagement <- quote ({


  observeEvent(input$native_lands, {

    req(input$native_lands)

    # Native lands layer
    native_land_geojson <- reactive({
      print(input$native_lands)
      switch(as.character(input$native_lands),
        "Off" = "off",
         "Territories" = file.path(data_path, "native_lands", "native_lands_territories.geojson"),
         "Languages" = file.path(data_path, "native_lands", "native_lands_languages.geojson"),
         "Treaties" = file.path(data_path, "native_lands", "native_lands_treaties.geojson"))
      })

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

      leafletProxy("ncc_map") %>%
        clearGroup(group = "Native Lands")

    }

  })


  observeEvent(input$reserves, {

    req(input$reserves)

    # Native lands layer
    reserves_sf <- reactive({
      switch(as.character(input$reserves),
             "Off" = "off",
             "BC" = reserves_bc,
             "AB" = reserves_ab,
             "SK" = reserves_sk,
             "MB" = reserves_mb,
             "ON" = reserves_on,
             "QC" = reserves_qc,
             "AT" = reserves_at,
             "YK" = reserves_yk,
             "NWT" = reserves_nwt,
             "NU" = reserves_nu)
    })

    if (input$reserves != "Off") {

      leafletProxy("ncc_map") %>%
        clearGroup(group = "Reserves") %>%
        addPolygons(data = reserves_sf(),
                    fillColor = "#ffff33",
                    color = "black",
                    weight = 1,
                    fillOpacity = 0.5,
                    group = "Reserves",
                    label = ~NAME1,
                    highlightOptions =
                      highlightOptions(weight = 5, color = "#ffff33")
        )
    } else {
      leafletProxy("ncc_map") %>%
        clearGroup(group = "Reserves")
    }
  })


  observeEvent(input$first_nation, {

    # Clear First Nation point
    if (length(input$first_nation) == 0) {
      leafletProxy("ncc_map") %>%
        clearGroup("First Nation Locations") %>%
        clearGroup("Tribal Councils") %>%
        clearGroup("Inuit Communities") %>%
        clearGroup("First Nation Reserves")
    } else {
      fn_groups <- c("First Nation Locations", "Tribal Councils", "Inuit Communities", "First Nation Reserves")
      fn_clear <- fn_groups[!(fn_groups %in% input$first_nation)]
      for (clear in fn_clear) {
        leafletProxy("ncc_map") %>%
          clearGroup(fn_clear)
      }
    }

    # Add First Nation points
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

      } else if (fn == "First Nation Reserves") {
        leafletProxy("ncc_map", data = aloc_points) %>%
          addMapPane("r_poly", zIndex = 698) %>%
          addMapPane("r_points", zIndex = 701) %>%
          addTiles(urlTemplate = ("tiles/reserves/{z}/{x}/{y}.png"),
                   options = pathOptions(pane = "r_poly"),
                   group = "First Nation Reserves") %>%

          # addCircleMarkers(label = ~NAME1,
          #                  group = "First Nation Reserves",
          #                  radius = 2,
          #                  color = "Black",
          #                  fillOpacity = 1,
          #                  weight = 0.2,
          #                  fillColor = "#ffff33",
          #                  clusterOptions = markerClusterOptions(),
          #                  options = pathOptions(pane = "r_points"))


#        leafletProxy("ncc_map") %>%
          addPolygons(data = aloc_poly,
                      fillColor = "#ffff33",
                      color = "black",
                      weight = 0,
                      fillOpacity = 0,
                      group = "First Nation Reserves",
                      label = ~NAME1)
        }
      # Close for-loop
      }
    # Close First Nation points observeEvent
    }, ignoreNULL = FALSE)
# Close quote
})
