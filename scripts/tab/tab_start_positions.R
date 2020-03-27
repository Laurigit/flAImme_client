# required_data("STG_TRACK_PIECE")
# input_STARTUP_DATA <- data.table(CYCLER_ID = c(1,2,3,4,5,6,7,8),
#                                  PLAYER_ID = c(1,1,2,2,3,3,4,4),
#                                  exhaust = c(0, 0, 0, 0, 0, 0,0,0),
#                                  starting_row =   c(1, 1, 2, 2, 3, 3,4,4),
#                                  starting_lane = c(1,2, 1, 2, 1, 2,1,2))
#
# game_status <- start_game(used_startup_data,
#                           input$select_track, STG_TRACK_PIECE, eR_TRACK())



start_pos_data <- reactive({

  curr_tour_cyclers <- tournament$data[TOURNAMENT_NM == input$join_tournament, TEAM_ID]
  curr_info <- ADM_CYCLER_INFO[TEAM_ID %in% curr_tour_cyclers]
  curr_info
})


output$cyclersInput <- renderUI({


  lapply(start_pos_data()[, UI_text],
         function(teksti) { tags$h3(drag = teksti,teksti)})
})

# output$cyclersPeloton <- renderUI({
#
#   div()
# })
output$ready <- renderUI({

  div()
})


observe({

  dragulaValue(input$dragula)$cyclersInput
  if (is.null(input$dragula)) {
    shinyjs::disable("start_game")
    shinyjs::disable("bet_for_breakaway")

  } else {
    shinyjs::enable("start_game")
    shinyjs::enable("bet_for_breakaway")
  }

})

observeEvent(input$continue_to_deck_handling, {
  updateTabItems(session, "sidebarmenu", selected = "tab_manage_deck")


})

observeEvent(input$start_game, {
  move_to$tab <- "tab_game_status"
  con <- connDB(con, "flaimme")
  command <- data.table(TOURNAMENT_NM = input$join_tournament, COMMAND = "START")
  dbIns("CLIENT_COMMANDS", command, con)

  updateTabItems(session, "sidebarmenu", selected = "tab_human_input")
})

observeEvent(input$bet_for_breakaway, {
  #move everyone to correct page
  updateTabItems(session, "sidebarmenu", selected = "tab_bet_for_breakaway")
  move_to$tab <-    move_to$tab + 1
})


observeEvent(c(
  input$start_game,
               input$bet_for_breakaway,
  1),
                {
#games starts from here!
  #get free game id

  #get previous game exhaust

  con <- connDB(con, "flaimme")
  cyclers <- start_pos_data()[, CYCLER_ID]
  track_id <- input$select_track


  #grid order

  grid_order <- data.table(UI_text = dragulaValue(input$dragula)$cyclersInput)


  #get ui_names back to cycler_ids
  join_ui_to_cycid <- start_pos_data()[grid_order, on = "UI_text"]
  #get slots
  #create temp track
  join_ui_to_cycid[, start_pos := seq_len(.N)]

  new_row_data <- data.table(TOURNAMENT_NM = input$join_tournament,
                             GAME_ID =  free_game_id(input$join_tournament, con),
                             CYCLER_ID = join_ui_to_cycid[, CYCLER_ID],
                             TRACK_ID = track_id,
                             SLOTS_OVER_FINISH = -1,
                             LANE = -1,
                             EXHAUST_LEFT = -1,
                             START_POSITION = join_ui_to_cycid[, start_pos])

  dbIns("TOURNAMENT_RESULT", new_row_data, con)

  tournament_result$data <- dbSelectAll("TOURNAMENT_RESULT", con)

}, ignoreInit = TRUE)




