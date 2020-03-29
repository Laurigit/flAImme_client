tabItem(tabName = "tab_game_status",
        fillPage(
          # fluidRow(
          #   actionBttn(inputId = "continue_from_game_status",
          #              label = "Continue",
          #              style = "material-flat",
          #              color = "success",
          #              size = "lg",
          #              block = TRUE
          #   )
          # ),

         # fluidRow(
          #  DT::dataTableOutput(outputId = "players")
            div(style = 'height:1200; overflow-y: scroll',
            plotOutput("game_map_both")
            )
         #   column(6, ),
          #  column(6,    )

        #  )

           # column(6,
           #        plotOutput("game_map_rouler")
           #        ),
           # column(6,
           #        plotOutput("game_map_sprinter")
           #        )
          # game_map_both
           # div(style = 'height:600px; overflow-y: scroll',
           #     plotOutput("game_map_both")
           # )



        )
)
