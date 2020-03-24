#tab_human_input
output$select_played_card <- renderUI({

  choices_input <- read from db

  radioGroupButtons(inputId = "select_played_card",
                    label = "Select card to play",
                    selected = NULL,
                    status = "success",
                    size = "lg",
                    direction = "horizontal",
                    justified = TRUE,
                    invidual = TRUE,
                    choices = choices_input
                    )

})
