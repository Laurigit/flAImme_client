tabItem(tabName = "tab_game_status",
        fluidPage(
          fluidRow(
         DT::dataTableOutput(outputId = "players")
          ),
         fluidRow(
           plotOutput("game_map")
         )

        )
)
