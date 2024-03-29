# Run extractions
extractions_UI <- function(id) {
  ns <- NS(id)
  tagList(
    br(),
    fluidRow(column(8, offset = 2, align = "center",
    actionButton(inputId = ns("run_extractions"), label = "Extract Impact Features",
                 icon = icon("play"), width = "100%")))
  )
}

extractions_SERVER <- function(id, user_pmp, proxy, user_pmp_region) {
  moduleServer(id, function(input, output, session) {

    # Return
    to_return <- reactiveValues(trigger = NULL, flag = NULL, user_pmp_mean = NULL,
                                user_pmp_nl = NULL)

    # Listen for run extraction button to be clicked
    observeEvent(input$run_extractions, {

    #Start progress bar
    withProgress(message = "Running extractions",
                   value = 0, max = 4, {	incProgress(1)

     tryCatch({

       # Load themes on first extraction run
       if (input$run_extractions == 1){
         id_ <- showNotification("... loading data", duration = 0, closeButton=close)
         theme_data <<- load_themes() # function that loads in all the rasters, store globally
         removeNotification(id_)
       }

       # Feature themes---------------------------------------------------------
       id_ <- showNotification("extracting: habitat data", duration = 0, closeButton=close)

       # Project to Canada Albers Equal Area Conic (national grid)
       user_pmp_102001 <- user_pmp() %>%
         st_transform(crs = st_crs("+proj=aea +lat_0=40 +lon_0=-96 +lat_1=50 +lat_2=70 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"))

       # Extract features (land cover, climate, recreation, etc.)
       user_pmp_feat <- exact_extract(theme_data$features, user_pmp_102001, fun = "sum", force_df = TRUE)
       names(user_pmp_feat) <- gsub("sum.", "", names(user_pmp_feat))
       user_pmp_feat <- user_pmp_feat %>%
         mutate(across(everything(), ~ replace_na(.x, 0)))

       # Species themes---------------------------------------------------------
       incProgress(2)
       removeNotification(id_)
       id_ <- showNotification("extracting: species data", duration = 0, closeButton=close)

       # Extract species (ECCC, NSC, IUCN)
       user_pmp_spp <- exact_extract(theme_data$species, user_pmp_102001, fun = "max", force_df = TRUE)
       names(user_pmp_spp) <- gsub("max.", "", names(user_pmp_spp))
       user_pmp_spp<- user_pmp_spp %>%
         mutate(across(everything(), ~ replace_na(.x, 0)))

       # Combine all extractions into one sf object ----------------------------
       user_pmp_mean <- cbind(user_pmp_102001, user_pmp_feat, user_pmp_spp)

       # Clean geometry, populate id, REGION and NAME field
       user_pmp_mean <- user_pmp_mean %>%
         st_make_valid() %>%
         mutate("id" = row_number()) %>%
         mutate("OBJECTID" = row_number()) %>% # Needed for native land table
         mutate("REGION" = user_pmp_region())

       # Calculate area ha
       user_pmp_mean$Area_ha <- units::drop_units(units::set_units(st_area(user_pmp_mean), value = ha))

       # Project to WGS
       user_pmp_mean <- st_transform(user_pmp_mean, crs = st_crs(4326))

       # Extract Native-Land.ca layers ----
       incProgress(3)
       removeNotification(id_)
       id_ <- showNotification("extracting: Indigenous data", duration = 0, closeButton=close)
       user_pmp_id <- user_pmp_mean %>% select(OBJECTID)
       native_lands_all <- geojsonsf::geojson_sf(file.path(data_path, "native_lands", "native_lands_all.geojson"))
       sf_use_s2(FALSE)
       user_pmp_nl <- sf::st_intersection(native_lands_all, user_pmp_id)
       sf_use_s2(TRUE)

       # Update map---------------------------------------------------------------
       user_extent <- st_bbox(user_pmp_mean)
       proxy %>%
         clearGroup("User PMP") %>%
         fitBounds(lng1  = user_extent[[1]], lat1 = user_extent[[2]],
                   lng2 =  user_extent[[3]], lat2 =  user_extent[[4]]) %>%
         addPolygons(data = user_pmp_mean,
                     layerId = ~id, # click event id selector
                     #label = ~htmlEscape(NAME),
                     popup = PMP_popup(user_pmp_mean, user = T),
                     options = pathOptions(clickable = TRUE),
                     weight = 1,
                     fillColor = "green",
                     group = "User PMP",
                     color = "black",
                     highlightOptions = highlightOptions(weight = 3,
                                                         color = '#00ffd9'))


       # Populate return objects
       to_return$flag <- 1
       to_return$trigger <- input$run_extractions
       to_return$user_pmp_mean <- user_pmp_mean
       to_return$user_pmp_nl <- user_pmp_nl

       # Finish progress bar
       incProgress(4)
       removeNotification(id_)
       showNotification("... Extractions Completed!", duration = 5, closeButton=TRUE, type = 'message')

     # Close try
     },

     # Show error message
     error = function(err){
       removeNotification(id_)
       showNotification("ERROR!", type = 'err', duration = 5, closeButton=close)
       showNotification(paste0(err), type = 'err', duration = 5, closeButton=close)
     })

   # Close progress bar
   })
  # Close observeEvent
  })

  # Return flag that indicates that the extractions ran
    return(to_return)

# Close module server
})
# Closer extraction_SERVER
}
