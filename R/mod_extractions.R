# Run extractions
extractions_UI <- function(id, label = "ui1UI") {
  ns <- NS(id)
  tagList(
    br(),
    fluidRow(column(8, offset = 2, align = "center",
    actionButton(inputId = ns("run_extractions"), label = "Extract Impact Themes", 
                 icon = icon("play"), width = "100%")))
  )
}

extractions_SERVER <- function(id, user_pmp, feat_stack, spp_stack, proxy) {
  moduleServer(id, function(input, output, session) {
    
    # Return 
    to_return <- reactiveValues(trigger = NULL, flag = NULL, user_pmp_mean = NULL )
    
    observeEvent(input$run_extractions, {
      
      #Start progress bar          
    withProgress(message = "Running extractions",
                   value = 0, max = 3, {	incProgress(1)
                     
     tryCatch({   
       
       # Feature themes---------------------------------------------------------  
       id_ <<- showNotification("... feature themes", duration = 0, closeButton=close)
       
       # Extract
       user_pmp_feat <- exact_extract(feat_stack, user_pmp(), fun = "sum", force_df = TRUE)
       names(user_pmp_feat) <- gsub("sum.", "", names(user_pmp_feat))
       user_pmp_feat <- user_pmp_feat %>%
         mutate(across(everything(), ~ replace_na(.x, 0)))
       
       # Species themes---------------------------------------------------------
       incProgress(2)
       removeNotification(id_)
       id_ <<- showNotification("... species themes", duration = 0, closeButton=close)
       
       # Extract
       user_pmp_spp <- exact_extract(spp_stack, user_pmp(), fun = "max", force_df = TRUE)
       names(user_pmp_spp) <- gsub("max.", "", names(user_pmp_spp))
       user_pmp_spp<- user_pmp_spp %>%
         mutate(across(everything(), ~ replace_na(.x, 0)))
       
       # Combine all extractions into one sf object -------------------------------
       user_pmp_mean <- cbind(user_pmp(), user_pmp_feat, user_pmp_spp) %>%
         st_transform(crs = st_crs(4326)) %>% # WGS 84
         st_make_valid()
       
       # Assign unique-ID
       user_pmp_mean$id <- 1:nrow(user_pmp_mean)
       
       # Update map---------------------------------------------------------------
       user_extent <- st_bbox(user_pmp_mean)
       proxy %>% 
         clearGroup("User PMP") %>%
         fitBounds(lng1  = user_extent[[1]], lat1 = user_extent[[2]], 
                   lng2 =  user_extent[[3]], lat2 =  user_extent[[4]]) %>%
         addPolygons(data = user_pmp_mean,
                     layerId = ~id, # click event id selector
                     #label = ~htmlEscape(NAME),
                     #popup = PMP_popup(user_pmp_mean),
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
       
       # Finish progress
       incProgress(3)
       removeNotification(id_)
       showNotification("... Extractions Completed!", duration = 0, closeButton=TRUE, type = 'message')
       
     # Close try 
     },
     
     # Show error message
     error = function(err){
       removeNotification(id_)
       showNotification("ERROR!", type = 'err', duration = 0, closeButton=close)
       showNotification(paste0(err), type = 'err', duration = 0, closeButton=close)
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