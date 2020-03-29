tabItem(tabName = "tab_game_status",
        fluidPage(
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

           # splitLayout(plotOutput("game_map_full"),


            # div(style = 'height:1000px; overflow-y: scroll',
            #     plotOutput("game_map_scroll")
            # )
          splitLayout(plotOutput("game_map_full"),
            div(style = 'height: 810px;, overflow-y: scroll',
                plotOutput("game_map_scroll")
            )
          ),

          uiOutput(outputId = "play_or_confirm")



        )
)
