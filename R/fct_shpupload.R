
# Load user shapefile
read_shp <- function(userFile){
  if (is.null(userFile)){
    return(NULL)
  }
  
  shp <- reactive({
    if(!is.data.frame(userFile())) return()
    infiles <- userFile()$datapath
    dir <- unique(dirname(infiles))
    outfiles <- file.path(dir, userFile()$name)
    name <- strsplit(userFile()$name[1], "\\.")[[1]][1] # strip name 
    purrr::walk2(infiles, outfiles, ~file.rename(.x, .y))
    x <- try(read_sf(file.path(dir, paste0(name, ".shp"))))
    if(class(x)=="try-error") NULL else x
  })
  
  return(shp)
  
}

#-------------------------------------------------------------------------------

# Display user shapefile
display_shp <- function (user_shp, map_id) {
    if(isTruthy(user_shp())) {
      user_shp_wgs <- user_shp() %>% st_transform(crs = st_crs(4326))
      user_extent <- st_bbox(user_shp_wgs)

      leafletProxy(map_id) %>%
        fitBounds(lng1  = user_extent[[1]], lat1 = user_extent[[2]], lng2 =  user_extent[[3]], lat2 =  user_extent[[4]]) %>%
        addPolygons(data = user_shp_wgs,
                    layerId = ~NULL,
                    options = pathOptions(clickable = T),
                    weight = 1,
                    label = ~htmlEscape("extract impact themes"),
                    fillColor = "grey",
                    color = "black",
                    group = "User PMP") %>%
        
        addLayersControl(overlayGroups = c("Project Mgmt. Plan", "User PMP"),
                         baseGroups = c("Streets", "Imagery", "Topographic"),
                         position = "bottomleft",
                         options = layersControlOptions(collapsed = F))       
      
    }
}
#-------------------------------------------------------------------------------

# Clear user shapefile
clear_shp <- function(reset_input, map_id, layer_name){
  
  reset(reset_input)
  leafletProxy(map_id) %>%
    clearGroup(group = layer_name) %>%
    addLayersControl(overlayGroups = c("Project Mgmt. Plan"),
                     baseGroups = c("Streets", "Imagery", "Topographic"),
                     position = "bottomleft",
                     options = layersControlOptions(collapsed = F)) 
  
  
}