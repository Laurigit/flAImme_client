tabItem(tabName = "tab_human_input",
        fluidPage(
          fluidRow(column(3, actionButton(inputId = "confirm_played_card",
                                          label = "Play selected card")),
                   column(offset = 2, width = 7, uiOutput(outputId = "select_played_card")))
        )
)
