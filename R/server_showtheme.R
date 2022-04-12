server_showtheme <- quote ({

  observeEvent(user_theme(),{

    if(user_theme() != F) {

      cons_pal <- colorNumeric(palette = "viridis", c(0,100))
      leafletProxy("ncc_map") %>%
        clearGroup(group= "convalue") %>%
        addMapPane("raster_map", zIndex = 900) %>%
        addTiles(urlTemplate = paste0("tiles/", user_theme(), "/{z}/{x}/{y}.png"),
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
})
