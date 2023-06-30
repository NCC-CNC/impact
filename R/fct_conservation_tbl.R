
# Single property data frame (variable | value)
PMP_table_single_property <- function(data, attributes, con_values, property, parcel) {

  ## columns layout (1 property per column)
  values_pulled <- purrr::map_chr(.x= con_values, .f = ~ {dplyr::pull(.data = data, var= .x)})

  # rounding
  values_pulled <- values_pulled %>% as.numeric() %>% round(2)

  # 1 property per column, used to for DT::replaceData
  pmp_df <- data.frame(attributes, values_pulled) %>%
    mutate(values_pulled = prettyNum(values_pulled, big.mark = ","))

}

# Single property empty table to render
pmp_empty_table <- function(attributes) {

  # 1 property per column
  pmp_df <- data.frame(attributes, values_pulled = NA)
  colnames = c("Conservation Variable", "Estimated Values")
  ordering = FALSE

  # render empty table
  pmp_dt <- DT::datatable(
    class = 'cell-border stripe',
    pmp_df,
    rownames = FALSE,
    colnames = colnames,
    extensions = c('FixedColumns',"FixedHeader"),
    options = list(
      dom = 't',
      ordering = ordering,
      paging = FALSE,
      fixedHeader = TRUE,
      fixedColumns = list(leftColumns = 1, rightColumns = 0)
    )
  )
}

# TEST FUNCTION ----------------------------------------------------------------

# pmp_selection <- PMP_tmp %>% dplyr::filter(id == 5)
#
# test <- NAT_table(data = pmp_selection,
#                    attributes = pmp_attributes,
#                    con_values = pmp_values)
#
#  test
#
# pmp_empty_table(pmp_attributes)
