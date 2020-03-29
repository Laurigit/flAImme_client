tabItem(tabName = "tab_rankings",
        fluidPage(
            fluidRow(uiOutput(outputId = "select_race")),
            fluidRow(DT::dataTableOutput(outputId = "show_race_stats")),
            fluidRow(DT::dataTableOutput(outputId = "show_tour_cylers")),
            fluidRow(DT::dataTableOutput(outputId = "show_tour_teamsc"))
        )
)

