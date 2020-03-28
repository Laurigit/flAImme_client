#tab_human_input
output$select_played_card <- renderUI({

  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
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
    moving_cycler <- 0
  })

  my_type <- ADM_CYCLER_INFO[CYCLER_ID == moving_cycler, CYCLER_TYPE_NAME]

  card_options <- choices_input[CYCLER_ID == moving_cycler & Zone == "Hand", CARD_ID]
  fluidRow(
           column(4,
                  disabled(actionBttn(inputId = "confirm_selected_card", label = "Confirm played card",
                             style = "material-flat", size = "lg", block = TRUE))
           ),
           column(4, offset = 4, radioGroupButtons(inputId = "select_played_card",
                    label = paste0(my_type, ": select card"),
                    selected = -1,
                    status = "success",
                    size = "lg",
                    direction = "vertical",
                    choices = card_options,
                    width = "100%"
                    ))
           )

})
observeEvent(input$select_played_card, {
  if (is.null(input$confirm_selected_card)) {
    shinyjs::disable("confirm_selected_card")
  } else {
    shinyjs::enable("confirm_selected_card")
  }
})


observeEvent(input$confirm_selected_card, {
  #save to db, update ui
  con <- connDB(con, "flaimme")
  played_card <- input$select_played_card

  if (played_card_status() == 2) {
    play_first <- 1
  }  else if (played_card_status() == 3) {
    play_first <- 0
  }
  turni <- get_current_turn(input$join_tournament, game_status_simple_current_game(), con)
  dbQ(paste0('update MOVE_FACT set CARD_ID = ', played_card,  ' where TEAM_ID = ',player_reactive$team, ' AND TOURNAMENT_NM = "', input$join_tournament, '"
  AND TURN_ID = ', turni, ' AND FIRST_SELECTED = ', play_first), con)

  move_fact$data <- dbSelectAll("MOVE_FACT", con)[GAME_ID == player_reactive$game & TOURNAMENT_NM == input$join_tournament]
  updateSelectInput(session, inputId = "select_played_card", selected = NULL)
  shinyjs::disable("confirm_selected_card")
})


output$select_which_cycler_plays_first <- renderUI({

  #check which cyclers I have left
  gs_data <- game_status_simple_current_game()
  max_gs_turn <- gs_data[, max(TURN_ID)]


  cyclers_left <- gs_data[TURN_ID == max_gs_turn & CYCLER_ID > 0, CYCLER_ID]
  my_options <- ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left & TEAM_ID == player_reactive$team, CYCLER_TYPE_NAME]

  fluidRow(column(6,
                  actionBttn(inputId = "confim_first_played_cycler",
                             label = "Confirm",
                             style = "material-flat",
                             color = "primary",
                             size = "lg",
                             block = FALSE)),
           column(6, radioGroupButtons(inputId = "radio_first_cycler",
                                       label = "Select first cycler to play",
                                       choices = my_options,
                                       selected = NULL,
                                       status = "info",
                                       direction = "vertical",
                                       size = "lg",
                                       width = "100%")))
})




observeEvent(input$confim_first_played_cycler, {
   selected_cycler <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == input$radio_first_cycler & TEAM_ID == player_reactive$team, CYCLER_ID]


   gs_data <- game_status_simple_current_game()
   max_gs_turn <- gs_data[, max(TURN_ID)]

   cyclers_left <- gs_data[TURN_ID == max_gs_turn & CYCLER_ID > 0, CYCLER_ID]


   my_options <- ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left & TEAM_ID == player_reactive$team, .N]



  #write to db update UI
  con <- connDB(con, "flaimme")

  turni <- get_current_turn(input$join_tournament, game_status_simple_current_game(), con)
  game <- curr_game_id(input$join_tournament, con)

  write_data_first <- data.table(TOURNAMENT_NM = input$join_tournament,
                           FIRST_SELECTED = 1,
                           CYCLER_ID = selected_cycler,
                           CARD_ID = -1,
                           GAME_ID = game,
                           TURN_ID = turni,
                           TEAM_ID = player_reactive$team)


  if (my_options == 2) {
    second_cycler <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME != input$radio_first_cycler & TEAM_ID == player_reactive$team, CYCLER_ID]
    write_data_second <- data.table(TOURNAMENT_NM = input$join_tournament,
                                    FIRST_SELECTED = 0,
                                    CYCLER_ID = second_cycler,
                                    CARD_ID = -1,
                                    TURN_ID = turni,
                                    GAME_ID = game,
                                    TEAM_ID = player_reactive$team )
  } else {
    write_data_second <- NULL
  }


  appendaa <- rbind(write_data_first, write_data_second)


  con <- connDB(con, "flaimme")
  dbWriteTable(con, "MOVE_FACT", appendaa, row.names = FALSE, append = TRUE)
  move_fact$data <- dbSelectAll("MOVE_FACT", con)[GAME_ID == player_reactive$game & TOURNAMENT_NM == input$join_tournament]
})
con <- connDB(con, "flaimme")
move_fact <- reactiveValues(data = NULL)

played_card_status <- reactive({

  #check if we are waiting for others to finish
  gid <- curr_game_id(input$join_tournament, con)
  mf_curr_game <- move_fact$data[TOURNAMENT_NM == input$join_tournament & GAME_ID == gid]
  played_total <- mf_curr_game[CARD_ID > 0, .N]

  #check how many moves I need to make this turn in case I am finished
  cyclers_left_total <- game_status_simple_current_game()[CYCLER_ID > 0, CYCLER_ID]
  missing_total <- length(cyclers_left_total) - played_total

  cyclers_left <- ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left_total & TEAM_ID == player_reactive$team, .N]
  current_turn <- get_current_turn(input$join_tournament, game_status_simple_current_game(), con)
  # #count cards waiting to be played
   count_cards_waiting <- mf_curr_game[TEAM_ID == player_reactive$team & CARD_ID < 0, .N]
   how_many_played <-  mf_curr_game[TEAM_ID == player_reactive$team & CARD_ID > 0  & TURN_ID == current_turn, .N]
   first_cycler_selected <- mf_curr_game[TEAM_ID == player_reactive$team & TURN_ID == current_turn , .N] > 0

   if (cyclers_left  == 0) {
     status <- 4
   } else if (first_cycler_selected == FALSE) {
    #I need to choose cycler
     status <- 1
   }  else if (how_many_played == 0) {
     # i need to choose first card
       status <- 2
     } else if (how_many_played == 1 & count_cards_waiting == 1) {
       #i need to choose 2nd card
      status <- 3
     } else if (missing_total > 0) {
       #i am ready, waiting others
       status <- 4
     } else {
       status <- 5
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

  shinyjs::disable("confirm_selected_card")
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

output$rouler_deck <- DT::renderDataTable({
  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
  choices_input <- choices_input_all[TURN_ID == (turni - 1) & HAND_OPTIONS == 0]
  cycler_input <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == "Rouler" & TEAM_ID == player_reactive$team, CYCLER_ID]
  resdata <- create_deck_stats(choices_input, cycler_input)
  resdt <- datatable(resdata,  caption = "Rouleur",  rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE, dom = 't',ordering = F))
})

output$sprinter_deck <- DT::renderDataTable({
  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
  choices_input <- choices_input_all[TURN_ID == (turni - 1) & HAND_OPTIONS == 0]
  cycler_input <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == "Sprinteur" & TEAM_ID == player_reactive$team, CYCLER_ID]
  resdata <- create_deck_stats(choices_input, cycler_input)
  resdt <- datatable(resdata, caption = "Sprinteur", rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE,
                                                                                      dom = 't',ordering = F)) %>% formatStyle(columns = c(1,2,3,4,5), width='1px')
})

output$other_decks <- DT::renderDataTable({
  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
  choices_input <- choices_input_all[TURN_ID == (turni - 1) & HAND_OPTIONS == 0]

  resdata <- create_comp_deck_status(choices_input, player_reactive$team, ADM_CYCLER_INFO)
  resdt <- datatable(resdata,  rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE,
                                                                                      dom = 't',ordering = F)) %>% formatStyle(columns = c(1,2,3,4,5), width='1px')

})

