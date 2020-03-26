#tab_human_input
output$select_played_card <- renderUI({

  choices_input <- deck_status_data()[TOURNAMENT_NM == input$join_tournament]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                    TEAM_ID == player_reactive$team & CARD_ID == -1]

  if (played_card_status() == 2) {
    moving_cycler <- cycler_options[FIRST_SELECTED == 1, CYCLER_ID]
  } else if (played_card_status() == 3) {
    moving_cycler <- cycler_options[FIRST_SELECTED == 0, CYCLER_ID]
  }  else ({
    break()
  })
  card_options <- choices_input[CYCLER_ID == moving_cycler & Zone == "Hand", CARD_ID]
  fluidRow(
           column(4,
                  actionBttn(inputId = "confirm_selected_card", label = "Confirm played card",
                             style = "material-flat", size = "lg", block = TRUE)
           ),
           column(4, offset = 4, radioGroupButtons(inputId = "select_played_card",
                    label = "Select card to play",
                    selected = NULL,
                    status = "success",
                    size = "lg",
                    direction = "vertical",
                    justified = TRUE,
                    individual = TRUE,
                    choices = card_options,
                    width = "400px"
                    ))
           )

})



observeEvent(input$confirm_selected_card, {
  #save to db, update ui
  con <- connDB(con, "flaimme")
  played_card <- input$select_played_card
  if (played_card_status() == 2) {
    play_first <- 1
  }  else if (played_card_status() == 3){
    play_first <- 0
  }
  turni <- get_current_turn(input$join_tournament, game_status_simple(), con)
  dbQ(paste0('update MOVE_FACT set CARD_ID = ', played_card,  ' where TEAM_ID = ',player_reactive$team, ' AND TOURNAMENT_NM = "', input$join_tournament, '"
  AND TURN_ID = ', turni, ' AND FIRST_SELECTED = ', play_first), con)
  move_fact$data <- dbSelectAll("MOVE_FACT", con)

})


output$select_which_cycler_plays_first <- renderUI({
  fluidRow(column(6,
                  actionBttn(inputId = "confim_first_played_cycler",
                             label = "Confirm",
                             style = "material-flat",
                             color = "primary",
                             size = "lg",
                             block = FALSE)),
           column(6, radioGroupButtons(inputId = "radio_first_cycler",
                                       label = "Select first cycler to play",
                                       choices = c("Rouler", "Sprinteur"),
                                       selected = NULL,
                                       status = "info",
                                       direction = "vertical",
                                       size = "lg",
                                       width = "100%")))
})


observeEvent(input$confim_first_played_cycler, {
   selected_cycler <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == input$radio_first_cycler & TEAM_ID == player_reactive$team, CYCLER_ID]
  second_cycler <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME != input$radio_first_cycler & TEAM_ID == player_reactive$team, CYCLER_ID]
  #write to db update UI
  con <- connDB(con, "flaimme")
  turni <- get_current_turn(input$join_tournament, game_status_simple(), con)

  write_data_first <- data.table(TOURNAMENT_NM = input$join_tournament,
                           FIRST_SELECTED = 1,
                           CYCLER_ID = selected_cycler,
                           CARD_ID = -1,
                           TURN_ID = turni,
                           TEAM_ID = player_reactive$team)


  write_data_second <- data.table(TOURNAMENT_NM = input$join_tournament,
                                 FIRST_SELECTED = 0,
                                 CYCLER_ID = second_cycler,
                                 CARD_ID = -1,
                                 TURN_ID = turni,
                                 TEAM_ID = player_reactive$team )

  appendaa <- rbind(write_data_first, write_data_second)


  con <- connDB(con, "flaimme")
  dbWriteTable(con, "MOVE_FACT", appendaa, row.names = FALSE, append = TRUE)
  move_fact$data <- dbSelectAll("MOVE_FACT", con)
})
con <- connDB(con, "flaimme")
move_fact <- reactiveValues(data = dbSelectAll("MOVE_FACT", con))

played_card_status <- reactive({

  # #count cards waiting to be played
   count_cards_waiting <- move_fact$data[TEAM_ID == player_reactive$team & CARD_ID < 0, .N]
  if (count_cards_waiting == 0) {
     status <- 1
   }  else if (count_cards_waiting == 2) {
       status <- 2
     } else if (count_cards_waiting == 1) {
      status <- 3
     }
return(status)

})

output$play_or_confirm <- renderUI({

  if (played_card_status() == 1) {
    uiOutput("select_which_cycler_plays_first")
  } else if(played_card_status() == 2) {
    uiOutput(outputId = "select_played_card")
  } else if(played_card_status() == 3) {
    uiOutput(outputId = "select_played_card")
  }
})
