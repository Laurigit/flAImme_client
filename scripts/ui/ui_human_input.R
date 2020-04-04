tabItem(tabName = "tab_human_input",
        fluidPage(
          fluidRow(div(DT::dataTableOutput(outputId = "players")), style = "50%"),
          fluidRow(splitLayout(div(DT::dataTableOutput(outputId = "sprinter_deck"), style = "font-size: 90%; width: 55%"),
                    div(DT::dataTableOutput(outputId = "rouler_deck"), style = "font-size: 90%; width: 55%"))),
          fluidRow(div(DT::dataTableOutput("other_decks"), style = "font-size: 80%; width: 100%")),
          fluidRow(actionBttn(inputId = "show_map", label = "Show map", style = "material-flat", color = "primary", size = "lg"))


          # fluidRow(column(3, actionButton(inputId = "confirm_played_card",
          #                                 label = "Play selected card")),
          #          column(offset = 2, width = 7, uiOutput(outputId = "select_played_card")))
        )
)

