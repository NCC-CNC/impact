
# Comparison modal window
comparison_UI <- function(id) {
  ns <- NS(id)
  tagList(
    # Ghost trigger for bs modal pop-up
    hidden(numericInput(inputId = ns("ghost_trigger"), value = 0, label = '' )),
    uiOutput(ns("compare_ui"))
  )
}

comparison_SERVER <- function(id, modal_trigger, compare_tbl, compare_plt,
                              user_pmp_mean, map_click, goals_csv,
                              user_pmp_property, user_pmp_parcel) {

  moduleServer(id, function(input, output, session) {

    ns <- NS(id)
    # Listen to compare button
    observeEvent(modal_trigger() , {


      # Do not execute until comparison button is clicked
      if (compare_tbl() !=0 | compare_plt() !=0) {

        # Build table, 1 feature per row
        pmp_table_SERVER(id = "pmp_table_mod2",
                         data = user_pmp_mean(),
                         attributes = pmp_attributes,
                         con_values = pmp_values,
                         property = user_pmp_property(),
                         parcel = user_pmp_parcel(),
                         modal = T)

        ## Advance ghost trigger to queue modal pop up
        updateNumericInput(session = session, inputId = 'ghost_trigger',
                           value = input$ghost_trigger + 1 )

        ## Generate comparison plots dynamically -----
        area_plots <- tagList()
        forest_plots <- tagList()
        grassland_plots <- tagList()
        wetland_plots <- tagList()
        river_plots <- tagList()
        lake_plots <- tagList()

        ## Populate plot themes based on the number of rows in sf object
        for (i in 1:(nrow(user_pmp_mean()))) {

          area_plots[[i]] <- plotlyOutput(ns(paste0("Area_ha", i)), height=100,width="100%")
          forest_plots[[i]] <- plotlyOutput(ns(paste0("Forest", i)), height=100,width="100%")
          grassland_plots[[i]] <- plotlyOutput(ns(paste0("Grassland", i)), height=100,width="100%")
          wetland_plots[[i]] <- plotlyOutput(ns(paste0("Wetland", i)), height=100,width="100%")
          river_plots[[i]] <- plotlyOutput(ns(paste0("River", i)), height=100,width="100%")
          lake_plots[[i]] <- plotlyOutput(ns(paste0("Lakes", i)), height=100,width="100%")

        }

        ## Render plot themes based on the number of rows in sf object
        for (i in 1:(nrow(user_pmp_mean()))) {

          local({
            my_i <- i

            output[[paste0("Area_ha", my_i)]] <- plot_theme("Area_ha", user_pmp_mean()[my_i,], goals_csv, user_pmp_mean()[my_i,][[user_pmp_parcel()]])
            output[[paste0("Forest", my_i)]] <- plot_theme("Forest", user_pmp_mean()[my_i,], goals_csv, user_pmp_mean()[my_i,][[user_pmp_parcel()]])
            output[[paste0("Grassland", my_i)]] <- plot_theme("Grassland", user_pmp_mean()[my_i,], goals_csv, user_pmp_mean()[my_i,][[user_pmp_parcel()]])
            output[[paste0("Wetland", my_i)]] <- plot_theme("Wetland", user_pmp_mean()[my_i,], goals_csv, user_pmp_mean()[my_i,][[user_pmp_parcel()]])
            output[[paste0("River", my_i)]] <- plot_theme("River", user_pmp_mean()[my_i,], goals_csv, user_pmp_mean()[my_i,][[user_pmp_parcel()]])
            output[[paste0("Lakes", my_i)]] <- plot_theme("Lakes", user_pmp_mean()[my_i,], goals_csv, user_pmp_mean()[my_i,][[user_pmp_parcel()]])

          })}

        ## Modal UI ----
        output$compare_ui <- renderUI({

          # BS Modal pop up
          fluidPage(mainPanel(
            bsModal(id = ns("compare"), "Compare New Properties",
                    "ghost_trigger", size="large",
            tabsetPanel(
              tabPanel("Table",
                       pmp_table_UI(id = ns("pmp_table_mod2"))),

              tabPanel("Plots",

                        tags$div(class = "theme-selection",
                        selectInput(
                         inputId = ns("theme_selection"), "", width = "100%",
                         choices = c("Area (ha)", "Forest (ha)", "Grassland (ha)",
                                     "Wetland (ha)", "River (km)", "Lakes (ha)"))),

                       # Dynamically generated plots
                       conditionalPanel(
                        condition = "input.theme_selection == 'Area (ha)'", ns = ns,
                        withSpinner(color = "#33862B", size = 1, proxy.height = "400px",
                        area_plots)),

                       conditionalPanel(
                         condition = "input.theme_selection == 'Forest (ha)'", ns = ns,
                         withSpinner(color = "#33862B", size = 1, proxy.height = "400px",
                         forest_plots)),

                       conditionalPanel(
                         condition = "input.theme_selection == 'Grassland (ha)'", ns = ns,
                         withSpinner(color = "#33862B", size = 1, proxy.height = "400px",
                         grassland_plots)),

                       conditionalPanel(
                         condition = "input.theme_selection == 'Wetland (ha)'", ns = ns,
                         withSpinner(color = "#33862B", size = 1, proxy.height = "400px",
                         wetland_plots)),

                       conditionalPanel(
                         condition = "input.theme_selection == 'River (km)'", ns = ns,
                         withSpinner(color = "#33862B", size = 1, proxy.height = "400px",
                         river_plots)),

                       conditionalPanel(
                         condition = "input.theme_selection == 'Lakes (ha)'", ns = ns,
                         withSpinner(color = "#33862B", size = 1, proxy.height = "400px",
                         lake_plots))))

            # Close bsModal
            )
          # Close mainPanel
          )
        # Close fluidPage
        )
      # Close renderUI
      })
    # Close if-statement
    }

  toggleModal(session, "compare", toggle = "open")

 # Close observeEvent
 })
# Close comparison_SERVER module
})}
