server_engagement <- quote ({


  observeEvent(input$native_lands, {

    req(input$native_lands)

    # Native lands layer
    native_land_geojson <- reactive({
      print(input$native_lands)
      switch(as.character(input$native_lands),
        "Off" = "off",
         "Territories" = file.path("inst", "extdata", "native_lands", "native_lands_territories.geojson"),
         "Languages" = file.path("inst", "extdata", "native_lands", "native_lands_languages.geojson"),
         "Treaties" = file.path("inst", "extdata", "native_lands", "native_lands_treaties.geojson"))
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


})
