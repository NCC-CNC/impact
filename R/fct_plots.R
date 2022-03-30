
bar1 <- function(current = NULL, potential = NULL, goal = NULL, label = NULL) {
  
  # create data
  d <- tibble(
    category = c("Current", "Potential", "Gap"),
    value0 = c(current, potential, goal),
    group = "group"
  )
  # convert values to relative differences
  d$value <- c(
    d$value0[1],
    d$value0[2],
    d$value0[3] - d$value0[1] - d$value0[2]
  )

  # convert to factor
  d <- d %>%
    mutate(category = factor(category, levels = c("Gap", "Potential", "Current")))

  # remove zeros if needed
  d <- d %>% filter(value > 0)

  # plot data
  p <- ggplot(d, aes(x = group, y = value)) +
    geom_col(aes(fill = category), width = 0.8) +
    coord_flip() +
    scale_fill_manual(
      values = alpha(
        c("Current" = "#1b9e77", "Potential" = "#d95f02", "Gap" = "#636363"),
        c(1, 1, 0.5)
      )
    ) +
    ylab(label) +
    xlab("") +
    labs(fill = "") +
    theme(legend.position = "none") +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank()
    ) +
    geom_hline(yintercept = goal, colour = "#636363", size = 1.2)

  ggplotly(p) %>% config(displayModeBar = F)

}



# User this function inside shiny
plot_theme <- function(theme, sf, goals_csv, label = NULL) {

    renderPlotly({
      
    bar1(current = goals_csv %>% 
           filter(Regions == sf$Regions) %>%
           filter(Category == "current") %>% 
           pull(theme) %>% round(0), 
         
         potential = round (sf[[theme]], 1), 
         
         goal = goals_csv %>% 
           filter(Regions == sf$Regions) %>%
           filter(Category == "goal") %>% 
           pull(theme) %>% round(0),
         
         label = label)
  })  
} 

# Test plots -------------------------------------------------------------------

# pmp_selection <- PMP_sub %>% dplyr::filter(NAME == 'Boreal A9 (outside of Birch River Wildland Park)')
# 
# current <- goals_csv %>%
#   filter(Regions == pmp_selection$Regions) %>%
#   filter(Category == "current") %>%
#   pull("Forest")
# 
# potential <- pmp_selection[["Forest"]]
# 
# goal <- goals_csv %>%
#   filter(Regions == pmp_selection$Regions) %>%
#   filter(Category == "goal") %>%
#   pull("Forest")
# 
# 
# bar1(current, potential, goal)
     

