tabItem(tabName = "tab_human_input",
        fluidPage(
          fluidRow(div(DT::dataTableOutput(outputId = "players")), style = "50%"),
          fluidRow(splitLayout(div(DT::dataTableOutput(outputId = "sprinter_deck"), style = "font-size: 70%; width: 50%"),
                    div(DT::dataTableOutput(outputId = "rouler_deck"), style = "font-size: 70%; width: 50%"))),
          fluidRow(div(DT::dataTableOutput("other_decks"), style = "font-size: 60%; width: 100%")),
          fluidRow(actionBttn(inputId = "show_map", label = "Show map", style = "material-flat", color = "primary", size = "lg"),
                   actionBttn(inputId = "show_sidebar", label = "show_sidebar map", style = "material-flat", color = "primary", size = "lg"))
        )
)
