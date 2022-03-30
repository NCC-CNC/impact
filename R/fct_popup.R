
PMP_popup <- function(data){
  paste0("<strong>Property: </strong>", data[["PROPERTY_N"]],
         "<br> <strong>Name: </strong>", data[["NAME"]],
         "<br><strong>Region: </strong>", data[["REGION"]],
         "<br><strong>Area: </strong>", format(round(data[["Area_ha"]], 1), nsmall=1, big.mark=","), " ha")
} 

# Generate table ---------------------------------------------------------------
PMP_table <- function(data, attributes, con_values) {
  
  ## SF objected with multiple rows ---- 
  if (nrow(data) > 1 ) {
    # Empty data frame to populate
    pmp_df <- data.frame()
    
    for (row in 1:(nrow(data))) {
    
      values_pulled <- purrr::map_chr(.x= con_values, .f = ~ {dplyr::pull(.data = data[row,], var=.x)})
      
      # Rounding 
      values_chr <- values_pulled[1:3]
      values_num <- values_pulled[4:length(values_pulled)] %>% as.numeric() %>% round(2) %>% as.character()
      values_pulled <- c(values_chr, values_num)      
    
      ## Row layout (1 property per row) 
      pmp_row <- data.frame(attributes, values_pulled) %>%
        pivot_wider(names_from = attributes, values_from = values_pulled)
  
      pmp_df <- rbind(pmp_df, pmp_row)
      
      # Set data table parameters for multiple rows
      colnames = attributes
      ordering = TRUE
    }
    
  } else {
    
    ## Columns layout (1 property per column) ----
    values_pulled <- purrr::map_chr(.x= con_values, .f = ~ {dplyr::pull(.data = data, var= .x)})
    # Rounding
    values_chr <- values_pulled[1:3]
    values_num <- values_pulled[4:length(values_pulled)] %>% as.numeric() %>% round(2) %>% as.character()
    values_pulled <- c(values_chr, values_num)
    
    
    pmp_df <- data.frame(attributes, values_pulled) 
  
    # Set data table parameters for 1 property per column
    colnames = c("", "")
    ordering = FALSE

  }
  
  ## Create table ----
  pmp_dt <- DT::datatable( class = 'white-space: nowrap',
    pmp_df, rownames=FALSE, colnames = colnames, extensions = c('FixedColumns',"FixedHeader"), 
    options = list(dom = 't',
                   ordering = ordering,
                   scrollX = TRUE,
                   scrollY = 'auto',
                   paging=FALSE,
                   fixedHeader=TRUE,
                   fixedColumns = list(leftColumns = 1, rightColumns = 0)))
    
}

# TEST FUNCTION ----------------------------------------------------------------
# 
# pmp_selection <- PMP_tmp %>% dplyr::filter(id < 5)
# 
# test <- PMP_table(data = pmp_selection,
#                   attributes = pmp_attributes,
#                   con_values = pmp_values)
# 
# test


