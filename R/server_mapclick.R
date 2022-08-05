server_mapclick <- quote ({

  # Initialize table
  property_title_SERVER(id = "property_mod1", data = data.frame(p1 = " ", p2 = " "), property_field = "p1", parcel_field = "p2")
  pmp_table_SERVER(id = "pmp_table_mod1", attributes = pmp_attributes)

  # Set table proxy's
  dt_table_proxy <- DT::dataTableProxy('pmp_table_mod1-pmp_table')

  # Listen for map click
  observeEvent(map_click(), {

    # Pause observe event until map click ID is truthy
    req(map_click()$id)

    # Logic for baseinput PMPs ----
    if(map_click()$group %in% c("British Columbia", "Alberta","Saskatchewan",
                                "Manitoba", "Ontario", "Quebec", "Atlantic",
                                "Yukon")) {

      ## Subset achievement sf by id ----
      user_pmp <- PMP_tmp %>% dplyr::filter(id == as.numeric(map_click()$id))

      ## Pull region
      user_region <- user_pmp %>% pull("REGION")
      print(user_region)

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
    }

    # Close map-click
  })

})
