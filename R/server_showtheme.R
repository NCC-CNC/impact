server_showtheme <- quote ({

  observeEvent(input$features,{

    if(input$features != "off" ) {
      shinyjs::show("continuous-legend-id")

      leafletProxy("ncc_map") %>%
        clearGroup(group = "tile_feature") %>%
        addMapPane("tile_feature", zIndex = 500) %>%
        addTiles(urlTemplate = paste0("tiles/", input$features, "/{z}/{x}/{y}.png"),
                 options = pathOptions(pane = "tile_feature"),
                 group = "tile_feature")
    } else {
      shinyjs::hide("continuous-legend-id")

      leafletProxy("ncc_map") %>%
        clearGroup(group= "tile_feature")
    }
  })
})
