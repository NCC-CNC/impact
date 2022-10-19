server_mapclick <- quote ({

  # Initialize empty title
  property_title_SERVER(id = "property_mod1", data = data.frame(p1 = " ", p2 = " "), property_field = "p1", parcel_field = "p2")

  # Initialize empty table
  pmp_table_SERVER(id = "pmp_table_mod1", attributes = pmp_attributes)
  eng_table_SERVER(id = "eng_table_mod1")

  # Set table proxy's
  dt_table_proxy <- DT::dataTableProxy('pmp_table_mod1-pmp_table')
  dt_eng_table_proxy <- DT::dataTableProxy('eng_table_mod1-eng_table')

  # Listen for map click
  observeEvent(map_click(), {

    # Pause observe event until map click ID is truthy
    req(map_click()$id)

    # Logic for baseinput PMPs ----
    if(map_click()$group %in% c("BC", "AB","SK", "MB",
                                "ON", "QC", "AT", "YK")) {

      ## Subset achievement sf by id ----
      user_pmp <- PMP_tmp %>% dplyr::filter(id == as.numeric(map_click()$id))

      ## Pull region
      user_region <- user_pmp %>% pull("REGION")

      ## Pull ObjectID
      OID <- user_pmp %>% pull("OBJECTID")

      ## Generate Table ----
      property_title_SERVER(id = "property_mod1",
                            data = user_pmp,
                            property_field = "PROPERTY_N",
                            parcel_field = "NAME")

      pmp_table_SERVER(id = "pmp_table_mod1",
                       data = user_pmp,
                       attributes = pmp_attributes,
                       con_values = pmp_values,
                       region = user_region,
                       goals_csv = goals_csv,
                       dt_proxy = dt_table_proxy,
                       modal = F)

      ## Generate plots ----
      shinyjs::show(id = "conditional_plots")
      property_title_SERVER(id = "property_mod2",
                            data = user_pmp,
                            property_field = "PROPERTY_N",
                            parcel_field = "NAME")

      output$Area <- plot_theme("Area_ha", user_pmp, goals_csv,  "Area (ha)")
      output$Forest <- plot_theme("Forest", user_pmp, goals_csv, "Forest (ha)")
      output$Grassland <- plot_theme("Grassland", user_pmp, goals_csv, "Grassland (ha)")
      output$Wetland <- plot_theme("Wetland", user_pmp, goals_csv, "Wetland (ha)")
      output$River <- plot_theme("River", user_pmp, goals_csv, "River (km)")
      output$Lakes <- plot_theme("Lakes", user_pmp, goals_csv, "Lakes (ha)")

      ## Engagement ----
      property_title_SERVER(id = "property_mod3",
                            data = user_pmp,
                            property_field = "PROPERTY_N",
                            parcel_field = "NAME")

      eng_table_SERVER(id = "eng_table_mod1",
                       oid = OID,
                       nl_ncc = nl_ncc,
                       dt_proxy = dt_eng_table_proxy)

    }

    # Logic for file input PMPs ----
    if(map_click()$group == "User PMP" ) {

      ## Subset dynamically-extracted sf by id ----
      user_pmp_new <- extracted$user_pmp_mean %>%
        dplyr::filter(id == as.numeric(map_click()$id))

      ## Generate Table ----
      property_title_SERVER(id = "property_mod1",
                            data = user_pmp_new,
                            property_field = user_pmp_property(),
                            parcel_field = user_pmp_parcel())

      pmp_table_SERVER(id = "pmp_table_mod1",
                       data = user_pmp_new,
                       attributes = pmp_attributes,
                       con_values = pmp_values,
                       region = user_pmp_region(),
                       goals_csv = goals_csv,
                       dt_proxy = dt_table_proxy,
                       modal = F)

      ## Generate plots ----
      shinyjs::show(id = "conditional_plots")
      property_title_SERVER(id = "property_mod2",
                            data = user_pmp_new,
                            property_field = user_pmp_property(),
                            parcel_field = user_pmp_parcel())

      output$Area <- plot_theme("Area_ha", user_pmp_new, goals_csv, "Area (ha)")
      output$Forest <- plot_theme("Forest", user_pmp_new, goals_csv, "Forest (ha)")
      output$Grassland <- plot_theme("Grassland", user_pmp_new, goals_csv, "Grassland (ha)")
      output$Wetland <- plot_theme("Wetland", user_pmp_new, goals_csv, "Wetland (ha)")
      output$River <- plot_theme("River", user_pmp_new, goals_csv, "River (km)")
      output$Lakes <- plot_theme("Lakes", user_pmp_new, goals_csv, "Lakes (ha)")

      ## Engagement ----
      OID <- user_pmp_new %>% pull("OBJECTID")
      property_title_SERVER(id = "property_mod3",
                            data = user_pmp_new,
                            property_field = user_pmp_property(),
                            parcel_field = user_pmp_parcel())

      eng_table_SERVER(id = "eng_table_mod1",
                       oid = OID,
                       nl_ncc = extracted$user_pmp_nl,
                       dt_proxy = dt_eng_table_proxy)

    }

    # Close map-click
  })

})
