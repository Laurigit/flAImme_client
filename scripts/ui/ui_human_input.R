tabItem(tabName = "tab_human_input",
        fluidPage(
          fluidRow(splitLayout(div(DT::dataTableOutput(outputId = "sprinter_deck"), style = "font-size: 100%; width: 55%"),
                    div(DT::dataTableOutput(outputId = "rouler_deck"), style = "font-size: 100%; width: 55%"))),
          fluidRow(DT::dataTableOutput("other_decks")),
          uiOutput(outputId = "play_or_confirm")


          # fluidRow(column(3, actionButton(inputId = "confirm_played_card",
          #                                 label = "Play selected card")),
          #          column(offset = 2, width = 7, uiOutput(outputId = "select_played_card")))
        )
)

