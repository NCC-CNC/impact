#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
  # Leave this function for adding external resources
  golem_add_external_resources(),
  # Your application UI logic

  navbarPage(
  "NCC Conservation Technology",
  tabPanel(class="pmp_tool", "Project Evaluation - DEV",

# Side-panel:-------------------------------------------------------------
    sidebarLayout(
      sidebarPanel(class = "side",
      ## Overview ----
      tabsetPanel(
        tabPanel("Overview",
          br(),
          wellPanel(includeMarkdown( app_sys("app/text/overview.md"))),

          # Logo
          img(class='logo', src='www/logos/stacked_logo_rgb_en.png')),

        ## Table ----
        tabPanel("Table",

          tags$div(class = "btn-compare",
          actionButton(style = "float: right;", inputId = "compare_tbl",
          label = "Compare", icon = icon("sliders-h"))),

          property_title_UI(id = "property_mod1"),
          pmp_table_UI(id = "pmp_table_mod1"),
          br(),br(),
          wellPanel(includeMarkdown(app_sys("app/text/table.md"))),

          width="100%"),

        ## Plots ----
        tabPanel("Plots",
          br(),
          tags$div(class= "btn-compare",
          actionButton(style = "float: right;", inputId = "compare_plt",
          label = "Compare", icon = icon("sliders-h"))),

          br(),
          hidden(div(id = "conditional_plots",
          withSpinner(color = "#33862B", size = 1,
          tagList(
            property_title_UI(id = "property_mod2"),
            plotlyOutput("Area",height=115,width="100%"),
            plotlyOutput("Forest",height=115,width="100%"),
            plotlyOutput("Grassland",height=115,width="100%"),
            plotlyOutput("Wetland",height=115,width="100%"),
            plotlyOutput("River",height=115,width="100%"),
            plotlyOutput("Lakes",height=115,width="100%"))))),

          br(),br(),
          wellPanel(includeMarkdown(app_sys("app/text/plot.md")))),

        ## Engagement ----
        tabPanel("Engagement",

          property_title_UI(id = "property_mod3"),
          eng_table_UI(id = "eng_table_mod1"),

          br(),

          ### Native-lands.ca layers
          fluidRow(
            radioButtons("native_lands", label = NULL,
                         choices = c("Off", "Territories", "Languages", "Treaties"),
                         inline = TRUE, width = '100%')
          ))

        # Close tabsetPanel
        )
      # Close sidebarPanel
      ),

      # Main-panel: ------------------------------------------------------------
      mainPanel(class = "main",

      ## NCC map ----
      withSpinner(color = "#33862B", size = 2, proxy.height = "100vh",
      leafletOutput(outputId = "ncc_map",
                    height = "calc(100vh - 100px)", width = "100%")),

        # Map sidebars---------------------------------------------------------
        sidebar_tabs(id = "map_sidebar", list(icon("upload")),

          ### Upload shapefile ----
          sidebar_pane(
            title = "Project Mgmt. Plan", id = "upload_sp",
            icon = icon("caret-right"),
            br(),

            # File upload
            wellPanel(includeMarkdown(app_sys("app/text/shp1a.md"))),
            fluidRow(column(9,
            fileInput(label = NULL,
            buttonLabel = tags$div("Upload", icon("upload"), style = "width: 90px"),
            inputId = "upload_pmp", "", width = "100%",
            accept = c(".shp", ".dbf", ".sbn", ".sbx", ".shx", ".prj"),
            multiple = TRUE)),

            # Clear button
            column(3,
            actionButton(inputId = "clear_pmp", label = "Clear", width = "100%"))),

            # Property and parcel name
            wellPanel(includeMarkdown(app_sys("app/text/shp1b.md"))),
            fluidRow(
              column(4,
              pickerInput(inputId = "region", "Region", width = "100%",
                          options = pickerOptions(noneSelectedText = "NA"),
                          choices = c())),

              column(4,
              pickerInput(inputId = "property", "Property", width = "100%",
                          options = pickerOptions(noneSelectedText = "NA"),
                                choices = c())),
              column(4,
              pickerInput(inputId = "parcel", "Parcel", width = "100%",
                            options = pickerOptions(noneSelectedText = "NA"),
                            choices = c()))),

            # Extractions button
            wellPanel(includeMarkdown(app_sys("app/text/shp2.md"))),
            extractions_UI(id = "extractions_mod1"),

            # Report button, hide for now ...
            br(),
            hidden(report_UI(id = "report_mod1")))

          # Close map-upload sidebar
          ),

    # Conservation themes ------------------------------------------------------
    tags$div( class = "raster-controls",
    h4(class = "raster-title", "Impact Features"),
    selectInput(
    inputId = "theme_selection", "", width = "100%",
    choices = c("No Selection" = F, "Forest(%)" = "forest",
                "Grassland(%)" = "grassland","Wetland(%)" = "wetland",
                "River(km)" = "rivers", "Lakes(%)" = "Lakes"))),

    # Comparison modal ---------------------------------------------------------
    comparison_UI(id = "compare_mod1")

  # Close mainPanel, # Close sidebarLayout,  Close tabPanel, # Close navbarPage
  ))))
# Close tagList, # Close app_ui
)}

#-------------------------------------------------------------------------------

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www", app_sys("app/www"))

  add_resource_path(
    "tiles", tile_path)

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "impact"
    ),
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()

    useShinyFeedback(),
    useShinyjs()

  )
}
