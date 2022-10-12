# Create an empty table to render
eng_empty_table <- function() {

  attributes <- c("Territories", "Languages", "Treaties", "Description")
  eng_df <- data.frame(attributes, values_pulled = NA)
  colnames = c("", "")
  ordering = FALSE

  # Render empty table
  eng_dt <- DT::datatable( class = 'white-space: nowrap',
                           escape = FALSE,
                           eng_df, rownames = FALSE, colnames = colnames,  extensions = c('FixedColumns',"FixedHeader"),
                           options = list(dom = 't',
                                          ordering = ordering,
                                          scrollX = TRUE,
                                          scrollY = 'auto',
                                          paging=FALSE,
                                          fixedHeader=TRUE,
                                          fixedColumns = list(leftColumns = 1, rightColumns = 0)))

  return(eng_dt)

}

# Create native-lands.ca table
eng_table <- function(gis_id, nl_ncc) {


  # Extract attributes
  native_lands <- nl_ncc %>% filter(GIS_ID == gis_id)
  territories <- paste(purrr::discard(unique(native_lands$Name_TER), is.na), collapse = '<br>')
  languages <-  paste(purrr::discard(unique(native_lands$Name_LAN), is.na), collapse = '<br>')
  treaties <- paste(purrr::discard(unique(native_lands$Name_TRE), is.na), collapse = '<br>')
  description <-  purrr::discard(unique(native_lands$description_TER), is.na)
  link <- paste(paste0("<a href='",description,"' target='blank'>",description,"</a>"), collapse = '<br>')

  # Build data frame
  attributes <- c("<b>Territories</b>", "<b>Languages</b>", "<b>Treaties</b>", "<b>Description</b>")
  values_pulled <- c( territories, languages, treaties, link)

  #  1 property per column, used to for DT::replaceData
  eng_df <- data.frame(attributes, values_pulled)

}


#nl_ncc <-  geojsonsf::geojson_sf(file.path("inst", "extdata", "native_lands", "native_lands_ncc.geojson"))
#df <- eng_table(447683, nl_ncc)
