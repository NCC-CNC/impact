
bar1 <- function(current = NULL, potential = NULL, goal = NULL, label = NULL) {

  # create data
  d <- tibble::tibble(category = c("Current", "Potential", "Gap"),
              value0 = c(current, potential, goal),group = "group")
  # convert values to relative differences
  d$value <- c(d$value0[1],
               d$value0[2],
               d$value0[3] - d$value0[1] - d$value0[2])

  # convert to factor
  d <- d %>%
    dplyr::mutate(category = factor(category, levels = c("Gap", "Potential", "Current")))

  # remove zeros if needed
  d <- d %>% dplyr::filter(value > 0)

  # plot data
  p <- ggplot2::ggplot(data = d,
                       mapping = aes(x = group, y = value)) +
    geom_col(aes(fill = category,
                 text = sprintf("%s: %s ha",
                                category,
                                format(value,
                                       big.mark = ",",
                                       scientific = FALSE))),
             colour="black", size = 0.2,  width = 0.5) +
    coord_flip() +
    scale_fill_manual(
      values = alpha(
        c("Current" = "#1b9e77", "Potential" = "#d95f02", "Gap" = "#ffffff"),
        c(1, 1, 0.5))) +
    ylab(label) +
    xlab("") +
    labs(fill = "") +
    theme(legend.position = "none") +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank()
    ) +
    geom_hline(aes(yintercept = goal,
                   text=sprintf("Goal: %s ha",
                                format(goal,
                                       big.mark = ",",
                                       scientific = FALSE))),
               colour = "#28282B", size = 0.8)

  # convert ggplot to plotly
  plotly::ggplotly(p, tooltip = "text") %>%
    plotly::config(displayModeBar = F) %>%
    layout(hovermode = "x")

}

# User this function inside shiny
plot_theme <- function(theme, sf, goals_csv, label = NULL) {

  renderPlotly({
    suppressWarnings(
    bar1(current = goals_csv %>%
           filter(Regions == sf$REGION) %>%
           filter(Category == "current") %>%
           pull(theme) %>% round(0),

         potential = round (sf[[theme]], 1),

         goal = goals_csv %>%
           filter(Regions == sf$REGION) %>%
           filter(Category == "goal") %>%
           pull(theme) %>% round(0),

         label = label))
    })
}

# Test plots -------------------------------------------------------------------

# pmp_selection <- PMP_tmp %>% dplyr::filter(NAME == 'Lot 5 363 740')
#
# current <- goals_csv %>%
#   filter(Regions == pmp_selection$REGION) %>%
#   filter(Category == "current") %>%
#   pull("Forest")
#
# potential <- pmp_selection[["Forest"]]
#
# goal <- goals_csv %>%
#   filter(Regions == pmp_selection$REGION) %>%
#   filter(Category == "goal") %>%
#   pull("Forest")
#
#
# bar1(current, potential, goal)

 # bc_pmp <- read_sf("../impactextractions/appdata/pmp/BC_Securement_FY23_24.shp")


