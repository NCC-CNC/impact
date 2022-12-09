
PMP_popup <- function(data, user = F){
  if (user == F) {
   popup <- paste0("<strong>Property: </strong>", data[["PRP_NAME"]],
                   "<br> <strong>Parcel: </strong>", data[["NAME"]],
                   "<br> <strong>Intrest: </strong>", data[["PCL_INTERE"]],
                   "<br> <strong>Securment Date: </strong>", data[["SE_DATE"]])
  } else {

    # Get fields names
    fields <- colnames(data)
    remove <- c("geometry", "id", pmp_values)
    fields <- setdiff(fields, remove)
    popup <- ""
    for (i in fields) {
      idx = which(fields == i)
      popup <- paste0(popup,
               paste0("<strong>", fields[idx],": </strong>", data[[i]], "<br>"))
    }

  }

  return(popup)

}

# Generate table ---------------------------------------------------------------
PMP_table <- function(data, attributes, con_values, property, parcel, region, goals_csv) {

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

      # 1 property per row
      pmp_df <- rbind(pmp_df, pmp_row)

    }

    # Set data table parameters for multiple rows
    colnames = attributes
    ordering = TRUE

    ## Create table, 1 property per row, used for renderDT ----
    pmp_dt <- DT::datatable( class = 'white-space: nowrap',
                             pmp_df, rownames=FALSE, colnames = colnames, extensions = c('FixedColumns',"FixedHeader"),
                             options = list(dom = 't',
                                            ordering = ordering,
                                            scrollX = TRUE,
                                            scrollY = 'auto',
                                            paging=FALSE,
                                            fixedHeader=TRUE,
                                            fixedColumns = list(leftColumns = 2, rightColumns = 0)))

  } else {

    ## Columns layout (1 property per column) ----
    values_pulled <- purrr::map_chr(.x= con_values, .f = ~ {dplyr::pull(.data = data, var= .x)})

    # Rounding
    values_pulled <- values_pulled %>% as.numeric() %>% round(2)

    ## Pull current
    raw <-  goals_csv %>%
      dplyr::filter(Regions == region & Category == "current") %>%
      unlist(., use.names=FALSE)

    # Remove region and category
    raw <- raw[3: length(raw)] %>% as.numeric()

    ## Build current
    current <- c(raw[1], NA, NA, NA, NA, NA, NA, NA, NA, raw[8], raw[9],
                 raw[10], raw[11], raw[12], raw[13], raw[2], raw[3], raw[4],
                 raw[5], raw[6], raw[7])

    ## Pull goal
    raw <-  goals_csv %>%
      dplyr::filter(Regions == region & Category == "goal") %>%
      unlist(., use.names=FALSE)

    # Remove region and category
    raw <- raw[3: length(raw)] %>% as.numeric()

    ## Build current
    goal <- c(raw[1], NA, NA, NA, NA, NA, NA, NA, NA, raw[8], raw[9],
                 raw[10], raw[11], raw[12], raw[13], raw[2], raw[3], raw[4],
                 raw[5], raw[6], raw[7])

    #  1 property per column, used to for DT::replaceData
    pmp_df <- data.frame(attributes, values_pulled, current, goal)
  }
}

# Create an empty table to render
pmp_empty_table <- function(attributes) {

  # 1 property per column
  pmp_df <- data.frame(attributes, values_pulled = NA, current = NA, goal = NA)
  colnames = c("", "Potential", "Current", "Goal")
  ordering = FALSE

  # Render empty table
  pmp_dt <- DT::datatable( class = 'white-space: nowrap',
                           pmp_df, rownames=FALSE, colnames = colnames, extensions = c('FixedColumns',"FixedHeader"),
                           options = list(dom = 't',
                                          ordering = ordering,
                                          paging=FALSE,
                                          fixedHeader=TRUE,
                                          fixedColumns = list(leftColumns = 1, rightColumns = 0)))
}

# TEST FUNCTION ----------------------------------------------------------------

# pmp_selection <- PMP_tmp %>% dplyr::filter(id == 5)
#
# test <- PMP_table(data = pmp_selection,
#                   attributes = pmp_attributes,
#                   con_values = pmp_values,
#                   region = 'Alberta',
#                   goals_csv = goals_csv)
#
# test

# pmp_empty_table(pmp_attributes)

