server_mapclick <- quote ({

  observeEvent(map_click(), {

    # Pause observe event until map click ID is truthy
    req(map_click()$id)

    # Logic for baseinput PMPs ----
    if(map_click()$group == "Project Mgmt. Plan" ) {

      ## Subset pre-extracted sf by id ----
      user_pmp <- PMP_tmp %>% dplyr::filter(id == as.numeric(map_click()$id))

      ## Generate Table ----
      property_title_SERVER(id = "property_mod1", data=user_pmp)
      pmp_table_SERVER(id = "pmp_table_mod1",
                       data = user_pmp,
                       attributes = pmp_attributes,
                       con_values = pmp_values)

      ## Generate plots ----
      shinyjs::show(id = "conditional_plots")
      property_title_SERVER(id = "property_mod2", data=user_pmp)
      output$Area <- plot_theme("Area_ha", user_pmp, goals_csv, "Area (ha)")
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
      property_title_SERVER(id = "property_mod1", data=user_pmp_new)
      pmp_table_SERVER(id = "pmp_table_mod1",
                       data = user_pmp_new,
                       attributes = pmp_attributes,
                       con_values = pmp_values)

      ## Generate plots ----
      shinyjs::show(id = "conditional_plots")
      property_title_SERVER(id = "property_mod2", user_pmp_new)
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
