
PMP_popup <- function(data, user = F){
  if (user == F) {
   popup <- paste0("<strong>Property: </strong>", data[["PROPERTY_N"]],
                   "<br> <strong>Parcel: </strong>", data[["NAME"]],
                   "<br> <strong>Intrest: </strong>", data[["CURRENT_NC"]],
                   "<br> <strong>Achievement: </strong>", data[["ACHIEVMNT"]],
                   "<br> <strong>Securment Date: </strong>", data[["DATE_SECUR"]])
  } else {
    # Get fields names
    fields <- colnames(data)
    remove <- c("geometry", "id", pmp_values)
    fields <- setdiff(fields, remove)
    popup <- ""
    for (i in seq_along(fields)) {
      popup <- paste0(popup,
               paste0("<strong>", fields[i],": </strong>", data[[i]], "<br>"))
    }

  }

  return(popup)

}

# Generate table ---------------------------------------------------------------
PMP_table <- function(data, attributes, con_values, property, parcel) {

  ## SF objected with multiple rows ----
  if (nrow(data) > 1 ) {
    # Empty data frame to populate
    pmp_df <- data.frame()

    # Add property and parcel to attribute and value list
    attributes <- c("Property", "Parcel", attributes)
    con_values <- c(property, parcel, con_values)

    for (row in 1:(nrow(data))) {

      values_pulled <- purrr::map_chr(.x= con_values, .f = ~ {dplyr::pull(.data = data[row,], var=.x)})

      # Rounding
      values_chr <- values_pulled[1:2]
      values_num <- values_pulled[3:length(values_pulled)] %>% as.numeric() %>% round(2) %>% as.character()
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
    values_pulled <- values_pulled %>% as.numeric() %>% round(2)

    # Set data table parameters for 1 property per column
    pmp_df <- data.frame(attributes, values_pulled)
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
                   fixedColumns = list(leftColumns = 2, rightColumns = 0)))

}

# TEST FUNCTION ----------------------------------------------------------------
#
# pmp_selection <- PMP_tmp %>% dplyr::filter(id == 5)
#
# test <- PMP_table(data = pmp_selection,
#                   attributes = pmp_attributes,
#                   con_values = pmp_values)
#
# test


