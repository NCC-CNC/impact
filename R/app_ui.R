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
  title = div("", img(src = "logos/NCC_Icon_Logo_KO_F.png",
                      height = "30px",
                      width = "40px",
                      style = "position: relative; margin:-15px 0px; display:right-align;")),

  # Main application tab
  tabPanel(class="pmp_tool", "Project Evaluation - dev",

# Side-panel:-------------------------------------------------------------
    sidebarLayout(
      sidebarPanel(class = "side",

      ## Properties ----
      tabsetPanel(
        tabPanel("Properties",
          br(),
          tags$div(class = "container-layers",
                   tags$div(class = "container-layers-buttons",
          ### NCC parcel layer with national themes extracted
          h5(class = "layers-title", "NCC Public Accomplishments"),
          fluidRow(column(12,
            prettyCheckboxGroup(inputId = "ncc_regions",
                                label = "",
                                status = "success",
                                choices = c("BC", "AB", "SK", "MB",
                                            "ON", "QC", "AT", "YK"),
                                inline = TRUE,
                                fill = FALSE))))),

          # Conservation features
          br(),
          tags$div(class = "container-layers",
          tags$div(class = "container-layers-buttons",
          ### NCC parcel layer with national themes extracted
          h5(class = "layers-title", "Conservation Features"),
          fluidRow(column(12,
            prettyRadioButtons(inputId = "features",
                                label = "",
                                status = "success",
                               choices = c("Off" = "off",
                                           "Forest" = "forest",
                                           "Grassland" = "grassland",
                                           "Wetland" = "wetland",
                                           "Lakes" = "lakes"),
                                inline = TRUE,
                                fill = FALSE)))),

          # Continuous Legend
          tags$div(id = "continuous-legend-id", class = "continuous-legend",
            tags$div(class = "continuous-legend-flex",
              tags$div(class = "color-bar"),
              tags$div(class = "units", HTML("&nbsp"), p("%"))
            ),
            tags$div(class = "items",
              tags$div(class = "item",
                tags$div(class = "tick"),
                tags$label(class = "colorbar-label", p("0"))
              ),
              tags$div(class = "item",
                       tags$div(class = "tick"),
                       tags$label(class = "colorbar-label", p("50"))
              ),
              tags$div(class = "item",
                       tags$div(class = "tick"),
                       tags$label(class = "colorbar-label", p("100"))
              )))),
      br(),

      # Overview help
      wellPanel(fluidRow(
        column(6,
          h5(class = "layers-title", "Help")),
        column(6, align="right",
          prettySwitch(
            inputId = "overview_switch",
            value = TRUE,
            inline = TRUE,
            label = "",
            status = "success",
            slim = TRUE))),

        tags$div(id = "overview_txt",
          includeMarkdown(app_sys("app/text/overview.md")))),

      # Close Properties tab
      ),

        ## Table ----
        tabPanel("Table",

          tags$div(class = "btn-compare",
          actionButton(style = "float: right;", inputId = "compare_tbl",
          label = "Compare", icon = icon("sliders-h"))),

          property_title_UI(id = "property_mod1"),
          pmp_table_UI(id = "pmp_table_mod1"),
          br(),br(),

          # Table help
          wellPanel(fluidRow(
            column(6,
                   h5(class = "layers-title", "Help")),
            column(6, align="right",
                   prettySwitch(
                     inputId = "table_switch",
                     value = TRUE,
                     inline = TRUE,
                     label = "",
                     status = "success",
                     slim = TRUE))),

            tags$div(id = "table_txt",
                     includeMarkdown(app_sys("app/text/table.md")))),

          width = "100%"),

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

          # Plot help
          wellPanel(fluidRow(
            column(6,
                   h5(class = "layers-title", "Help")),
            column(6, align="right",
                   prettySwitch(
                     inputId = "plot_switch",
                     value = TRUE,
                     inline = TRUE,
                     label = "",
                     status = "success",
                     slim = TRUE))),

            tags$div(id = "plot_txt",
                     includeMarkdown(app_sys("app/text/plot.md"))))
          ),

        ## Engagement ----
        tabPanel("Engagement",

          property_title_UI(id = "property_mod3"),
          eng_table_UI(id = "eng_table_mod1"),
          br(),

          tags$div(class = "container-layers",
          tags$div(class = "container-layers-buttons",
          ### Native-lands.ca layers
          h5(class = "engagement-layers-title", a("Native-Land.ca", href="https://native-land.ca/", target="_blank")),
          fluidRow(column(12,
            prettyRadioButtons(inputId = "native_lands",
                               label = "",
                               status = "success",
                               choices = c("Off", "Territories", "Languages", "Treaties"),
                               inline = TRUE,
                               fill = FALSE))),

          ### First Nation points
          h5(class = "engagement-layers-title",
             a("First Nation Profiles", href="https://fnp-ppn.aadnc-aandc.gc.ca/fnp/Main/Index.aspx?lang=eng",
               target="_blank")),
          fluidRow(column(12,
            prettyCheckboxGroup(
              inputId = "first_nation",
              label = "",
              status = "success",
              choices = c("First Nation Locations", "Tribal Councils", "Inuit Communities"),
              inline = TRUE,
              fill = FALSE
          ))),

          ### First Nation Reserve layers
          h5(class = "engagement-layers-title",
             a("Aboriginal Lands of Canada Legislative Boundaries",
               href="https://open.canada.ca/data/en/dataset/522b07b9-78e2-4819-b736-ad9208eb1067",
               target="_blank")),
          fluidRow(column(12,
            prettyRadioButtons(inputId = "reserves",
                               label = "",
                               status = "success",
                               choices = c("Off", "BC", "AB", "SK", "MB", "ON",
                                          "QC", "AT", "YK", "NWT", "NU"),
                               inline = TRUE,
                               fill = FALSE)))
          # Close indigenous layers
          )),

          br(),
          # Indigenous help
          wellPanel(fluidRow(
            column(6,
                   h5(class = "layers-title", "Help")),
            column(6, align="right",
                   prettySwitch(
                     inputId = "indigenous_switch",
                     value = TRUE,
                     inline = TRUE,
                     label = "",
                     status = "success",
                     slim = TRUE))),

            tags$div(id = "indigenous_txt",
                     includeMarkdown(app_sys("app/text/indigenous.md"))))

          # Close engagement tab
          )
        # Close tabsetPanel
        )
      # Close sidebarPanel
      ),

      # Main-panel: ------------------------------------------------------------
      mainPanel(class = "main",

      ## NCC map ----
      loading_message(id = "leafletBusy",
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

            # Download button
            br(),
            download_UI(id = "download_mod1"))

          # Close map-upload sidebar
          ),

    # Comparison modal ---------------------------------------------------------
    comparison_UI(id = "compare_mod1")

  # Close mainPanel, # Close sidebarLayout,  Close Main tabPanel,
  )))

# Close navbarPage
)
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
    "logos", app_sys("app/www/logos"))

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
