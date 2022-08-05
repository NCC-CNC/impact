library(leaflet)
library(shiny)
library(shinyWidgets)
library(sf)
library(dplyr)
library(htmltools)
library(shinyjs)
library(htmlwidgets)

setwd("C:/Github/impact")
source(file.path("R", "fct_popup.R"))

# read-in basedata
data_path <- normalizePath(file.path("..", "impactextractions", "appdata"))
load(file.path(data_path, "basedata.RData"))

#
jsCode <- "shinyjs.addMarker = function() {new L.marker([51, -114]).addTo(mymap);}"

# subset achievement polygon by region
bc <- PMP_tmp %>% filter(REGION == "British Columbia")
ab <- PMP_tmp %>% filter(REGION == "Alberta")
sk <- PMP_tmp %>% filter(REGION == "Saskatchewan")
mb <- PMP_tmp %>% filter(REGION == "Manitoba")
on <- PMP_tmp %>% filter(REGION == "Ontario")
qc <- PMP_tmp %>% filter(REGION == "Quebec")
at <- PMP_tmp %>% filter(REGION == "Atlantic")
yk <- PMP_tmp %>% filter(REGION == "Yukon")

# create named list of achievements
achievements <- list("British Columbia" = bc, "Alberta" = ab, "Saskatchewan" = sk,
                     "Manitoba" = mb, "Ontario" = on, "Quebec" = qc,
                     "Atlantic" = at, "Yukon" = yk)



# Create a manual cache list that flags if data has been loaded
cached <- list("British Columbia" = 0, "Alberta" = 0, "Saskatchewan" = 0,
            "Manitoba" = 0, "Ontario" = 0, "Quebec" = 0,
            "Atlantic" = 0, "Yukon" = 0)
# UI ----
ui <- shiny::fluidPage(
  useShinyjs(),
  extendShinyjs(script = file.path("tests", "examples", "toggle_layer_controls.js"), functions = c("addMarker")),
  leaflet::leafletOutput(outputId = "mymap", height = "800px"),
  tags$hr(),
  tags$p("Button to run the JS code"),
  actionButton(inputId = "go", label = "Add a Marker")
# Close UI
)

# Server ----
server <- function(input, output, session) {

  # init leaflet map with achievement layers no loaded and controls turned off
  output$mymap <- leaflet::renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      # middle of Canada
      setView(lng = -96.28, lat = 62.24, zoom = 4) %>%
      addLayersControl(overlayGroups = c('British Columbia', "Alberta", "Saskatchewan",
                                         "Manitoba", "Ontario", "Quebec", "Atlantic",
                                         "Yukon"),
                       baseGroups = c("Topographic", "Imagery", "Streets"),
                       position = "bottomleft",
                       options = layersControlOptions(collapsed = F)) %>%

      htmlwidgets::onRender("
            function(el,x) {
                map = this;
            }
        ") %>%


      htmlwidgets::onRender("
        function() { $('.leaflet-control-layers-overlays').prepend('<label style=\"text-align:center\">Achievments</label>');
            $('.leaflet-control-layers-list').prepend('<label style=\"text-align:center\">Basemaps</label>');
        }
    ") %>%

      hideGroup("British Columbia") %>%
      hideGroup("Alberta") %>%
      hideGroup("Saskatchewan") %>%
      hideGroup("Manitoba") %>%
      hideGroup("Ontario") %>%
      hideGroup("Quebec") %>%
      hideGroup("Atlantic") %>%
      hideGroup("Yukon")
  })

  observeEvent(
    eventExpr = input$go,
    handlerExpr = js$addMarker()
  )

  # Load achievement polygons by region when selected in layer controls. Only load once.
  observeEvent(input$mymap_groups, {

    # remove base groups
    layer_on <- input$mymap_groups[!(input$mymap_groups %in% c("Topographic","Imagery","Streets"))]
    print(layer_on)

    if (length(layer_on) > 0) {

      # zoom to layer extent
      PMP_region <- PMP_tmp %>%
        dplyr::filter(stringr::str_detect(REGION, layer_on))

      region_extent <- st_bbox(PMP_region)
      leafletProxy("mymap") %>%
        fitBounds(lng1  = region_extent[[1]], lat1 = region_extent[[2]],
                  lng2 =  region_extent[[3]], lat2 =  region_extent[[4]])

      # update cached list by adding
      for(i in layer_on) {
        cached[[i]] <<-  cached[[i]] + 1
        }

      # add polygon
      for(name in  names(cached)){

        if (cached[[name]] == 1) {
          data <- achievements[name][[1]]
          leafletProxy("mymap") %>%
            addPolygons(data = data,
                        group = name,
                        layerId = ~id, # click event id selector
                        label = ~htmlEscape(NAME),
                        popup = PMP_popup(data), # fct_popup.R
                        fillColor = "#33862B",
                        color = "black",
                        weight = 1,
                        fillOpacity = 0.7,
                        highlightOptions = highlightOptions(weight = 3, color = '#00ffd9'))
        }
      }
      }


  })


}
shinyApp(ui, server)

