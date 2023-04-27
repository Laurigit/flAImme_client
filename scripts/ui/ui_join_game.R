tabItem(tabName = "tab_join_game",
        fluidPage(uiOutput(outputId = "select_tournament"),
                  uiOutput(outputId = "my_name_is"),
                  actionButton(inputId = "save_me",
                               label = "Confirm selection",
                               disabled = TRUE))
)

