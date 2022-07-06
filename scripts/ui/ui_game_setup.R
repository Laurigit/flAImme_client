tabItem(tabName = "tab_game_setup",
        fluidPage(
          fluidRow(
            column(4, textInput("game_name", value = "",
                                label = "Name the tournament",
                                placeholder = "Lauri's game"))
          ),
          fluidRow(
            column(6,
          fluidRow(

            radioButtons(inputId = "blue_setup",
                                         label = "Blue team",
                                         choices = c("Human", "AI", "AI autocards", "Not playing"),
                                         selected = "Human"
                                       #  direction = "horizontal"
                                         ),
                   textInput(inputId = "blue_name",
                             label = "Player name",
                             value = "",
                             placeholder = "Name of blue player")
                   ),
          fluidRow( radioButtons(inputId = "red_setup",
                                      label = "Red team",
                                      choices = c("Human", "AI", "AI autocards", "Not playing"),
                                      selected = "Human"
                                #      direction = "horizontal"
                    ),
                    textInput(inputId = "red_name",
                              label = "Player name",
                              value = "",
                              placeholder = "Name of red player")
          ),
          fluidRow( radioButtons(inputId = "green_setup",
                                      label = "Green team",
                                      choices = c("Human", "AI", "AI autocards", "Not playing"),
                                      selected = "Human"
                                    #  direction = "horizontal"
          ),
          textInput(inputId = "green_name",
                    label = "Player name",
                    value = "",
                    placeholder = "Name of green player")

          )),
          column(6,
          fluidRow( radioButtons(inputId = "black_setup",
                                      label = "Black team",
                                      choices = c("Human", "AI", "AI autocards", "Not playing"),
                                      selected = "Human"
                                    #  direction = "horizontal"
          ),
          textInput(inputId = "black_name",
                    label = "Player name",
                    value = "",
                    placeholder = "Name of black player")

          ),
          fluidRow( radioButtons(inputId = "white_setup",
                                      label = "White team",
                                      choices = c("Human", "AI", "AI autocards", "Not playing"),
                                      selected = "Human"
                                   #   direction = "horizontal"
          ),
          textInput(inputId = "white_name",
                    label = "Player name",
                    value = "",
                    placeholder = "Name of white player")

          ),
          fluidRow( radioButtons(inputId = "purple_setup",
                                      label = "Purple team",
                                      choices = c("Human", "AI", "AI autocards", "Not playing"),
                                      selected = "Human"
                                    #  direction = "horizontal"
          ),
          textInput(inputId = "purple_name",
                    label = "Player name",
                    value = "",
                    placeholder = "Name of purple player")
          )
        ),
        fluidRow(actionButton(inputId = "save_players",
                              label = "Save players and continue",
                              width = "100%"))


    )

)
)

