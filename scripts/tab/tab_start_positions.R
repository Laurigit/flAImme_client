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
print("start_pos_data")
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
    shinyjs::disable("save_initial_grid")


  } else {
    shinyjs::enable("save_initial_grid")

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
  shinyjs::disable("bet_for_breakaway")
  shinyjs::disable("start_game")
})

observeEvent(input$bet_for_breakaway, {
  print("bet_for_breakaway")

  #move everyone to correct page
  updateTabItems(session, "sidebarmenu", selected = "tab_bet_for_breakaway")

  command <- data.table(TOURNAMENT_NM = input$join_tournament, COMMAND = "BREAKAWAY")
  dbIns("CLIENT_COMMANDS", command, con)
  shinyjs::disable("bet_for_breakaway")
  shinyjs::disable("start_game")
})


observe({

req(input$join_tournament)
  if (nrow(game_status_simple_current_game()) > 0) {
        newest_game <- game_status_simple_current_game()[, max(GAME_ID)]
        newest_game_turn <- game_status_simple_current_game()[GAME_ID == newest_game, max(TURN_ID)]
        players_in_latest_game <- tournament_result$data[TOURNAMENT_NM == input$join_tournament & GAME_ID == newest_game, .N]
        finished_players <- tournament_result$data[TOURNAMENT_NM == input$join_tournament & GAME_ID == newest_game & FINISH_TURN > 0, .N]
        latest_game_finished <- players_in_latest_game == finished_players
        if (latest_game_finished) {
          #pevious game started, no new
          shinyjs::enable("save_initial_grid")
          shinyjs::disable("bet_for_breakaway")
          shinyjs::disable("start_game")
        } else if ( latest_game_finished == FALSE & newest_game_turn < 1) {
          #start game pressend, but not continued
          shinyjs::disable("save_initial_grid")
        shinyjs::enable("bet_for_breakaway")
        shinyjs::enable("start_game")
      } else {
        #game on
        shinyjs::disable("save_initial_grid")
        shinyjs::disable("bet_for_breakaway")
        shinyjs::disable("start_game")
      }
  }
})

observeEvent(input$save_initial_grid, {
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
  new_game_id <- free_game_id(input$join_tournament, con)
  new_row_data <- data.table(TOURNAMENT_NM = input$join_tournament,
                             GAME_ID =  new_game_id,
                             CYCLER_ID = join_ui_to_cycid[, CYCLER_ID],
                             TRACK_ID = track_id,
                             FINISH_TURN = -1,
                             SLOTS_OVER_FINISH = -1,
                             LANE = -1,
                             EXHAUST_LEFT = -1,
                             START_POSITION = join_ui_to_cycid[, start_pos])

  dbIns("TOURNAMENT_RESULT", new_row_data, con)

  tournament_result$data <- dbSelectAll("TOURNAMENT_RESULT", con)
  command <- data.table(TOURNAMENT_NM = input$join_tournament, COMMAND = "SETUP")
  dbIns("CLIENT_COMMANDS", command, con)
  shinyjs::enable("bet_for_breakaway")
  shinyjs::enable("start_game")

  player_reactive$game <- new_game_id
  move_fact$data <- dbSelectAll("MOVE_FACT", con)[GAME_ID == player_reactive$game & TOURNAMENT_NM == input$join_tournament]
})


observeEvent(c(
  input$start_game,
               input$bet_for_breakaway,
  1),
                {

}, ignoreInit = TRUE)


observeEvent(input$start_after_betting, {
  #tell server we are ready and check that it has not been tol

  command <- data.table(TOURNAMENT_NM = input$join_tournament, COMMAND = "BREAKAWAY_DONE")
  dbIns("CLIENT_COMMANDS", command, con)
  updateTabItems(session, "sidebarmenu", selected = "tab_manage_deck")

})


