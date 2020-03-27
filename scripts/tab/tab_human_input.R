#tab_human_input
output$select_played_card <- renderUI({

  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                    TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
  choices_input <- choices_input_all[TURN_ID == turni]
  if (played_card_status() == 2) {
    moving_cycler <- cycler_options[FIRST_SELECTED == 1, CYCLER_ID]
  } else if (played_card_status() == 3) {
    moving_cycler <- cycler_options[FIRST_SELECTED == 0, CYCLER_ID]
  }  else ({
   # move_to$tab <- "tab_game_status"
    #updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
  })

  my_type <- ADM_CYCLER_INFO[CYCLER_ID == moving_cycler, CYCLER_TYPE_NAME]

  card_options <- choices_input[CYCLER_ID == moving_cycler & Zone == "Hand", CARD_ID]
  fluidRow(
           column(4,
                  actionBttn(inputId = "confirm_selected_card", label = "Confirm played card",
                             style = "material-flat", size = "lg", block = TRUE)
           ),
           column(4, offset = 4, radioGroupButtons(inputId = "select_played_card",
                    label = paste0(my_type, ": select card"),
                    selected = NULL,
                    status = "success",
                    size = "lg",
                    direction = "vertical",
                    choices = card_options,
                    width = "100%"
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
  game <- curr_game_id(input$join_tournament, con)

  write_data_first <- data.table(TOURNAMENT_NM = input$join_tournament,
                           FIRST_SELECTED = 1,
                           CYCLER_ID = selected_cycler,
                           CARD_ID = -1,
                           GAME_ID = game,
                           TURN_ID = turni,
                           TEAM_ID = player_reactive$team)


  write_data_second <- data.table(TOURNAMENT_NM = input$join_tournament,
                                 FIRST_SELECTED = 0,
                                 CYCLER_ID = second_cycler,
                                 CARD_ID = -1,
                                 TURN_ID = turni,
                                 GAME_ID = game,
                                 TEAM_ID = player_reactive$team )

  appendaa <- rbind(write_data_first, write_data_second)


  con <- connDB(con, "flaimme")
  dbWriteTable(con, "MOVE_FACT", appendaa, row.names = FALSE, append = TRUE)
  move_fact$data <- dbSelectAll("MOVE_FACT", con)
})
con <- connDB(con, "flaimme")
move_fact <- reactiveValues(data = dbSelectAll("MOVE_FACT", con))

played_card_status <- reactive({

  #check if we are waiting for others to finish
  waiting_others <- move_fact$data[CARD_ID < 0, .N]

  # #count cards waiting to be played
   count_cards_waiting <- move_fact$data[TEAM_ID == player_reactive$team & CARD_ID < 0, .N]
  if (count_cards_waiting == 0) {
    #I need to choose cycler
     status <- 1
   }  else if (count_cards_waiting == 2) {
     # i need to choose first card
       status <- 2
     } else if (count_cards_waiting == 1) {
       #i need to choose 2nd card
      status <- 3
     } else if (count_cards_waiting == 0 & wating_others > 0) {
       #i am ready, waiting others
       status <- 4
     } else {
       status <- NA
     }
return(status)

})

output$act_button_continue <- renderUI({
  actionBttn(inputId = "continue_to_game_status_from_select_card",
             label = "Continue",
             style = "material-flat",
             size = "lg",
             block = TRUE)
})

observeEvent(input$continue_to_game_status_from_select_card,{
  updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
})

output$play_or_confirm <- renderUI({

  if (played_card_status() == 1) {
    uiOutput("select_which_cycler_plays_first")
  } else if(played_card_status() == 2) {
    uiOutput(outputId = "select_played_card")
  } else if(played_card_status() == 3) {
    uiOutput(outputId = "select_played_card")
  } else {
    uiOutput(outputId = "continue_to_game_status")
  }
})
