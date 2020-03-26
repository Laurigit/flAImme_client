tabItem(tabName = "tab_game_status",
        fluidPage(
          fluidRow(
         DT::dataTableOutput(outputId = "players")
          ),
         fluidRow(
           # column(6,
           #        plotOutput("game_map_rouler")
           #        ),
           # column(6,
           #        plotOutput("game_map_sprinter")
           #        )
          # game_map_both
           plotOutput("game_map_both")
         ),
         fluidRow(
           actionBttn(inputId = "continue_from_game_status",
                      label = "Continue",
                      style = "material-flat",
                      color = "success",
                      size = "lg",
                      block = TRUE
                      )
         )

        )
)
