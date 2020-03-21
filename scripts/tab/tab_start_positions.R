# required_data("STG_TRACK_PIECE")
# input_STARTUP_DATA <- data.table(CYCLER_ID = c(1,2,3,4,5,6,7,8),
#                                  PLAYER_ID = c(1,1,2,2,3,3,4,4),
#                                  exhaust = c(0, 0, 0, 0, 0, 0,0,0),
#                                  starting_row =   c(1, 1, 2, 2, 3, 3,4,4),
#                                  starting_lane = c(1,2, 1, 2, 1, 2,1,2))
#
# game_status <- start_game(used_startup_data,
#                           input$select_track, STG_TRACK_PIECE, eR_TRACK())




output$cyclersInput <- renderUI({


  lapply(c(eRstartPosData()[, UI_text], "READY"),
         function(teksti) { tags$h3(drag = teksti,teksti)})
})

# output$cyclersPeloton <- renderUI({
#
#   div()
# })
output$ready <- renderUI({

  div()
})


observeEvent(input$continue_to_deck_handling, {
  updateTabItems(session, "sidebarmenu", selected = "tab_manage_deck")


})


observeEvent(input$save_initial_grid, {
#games starts from here!
  #get free game id

  #get previous game exhaust

  tournament_data <- tournament$data[TOURAMENT_NM == input$join_tournament]
  cyclers <- tournament_data[, CYCLER_ID]
  track_id <- input$select_track
  new_row_data <- data.table(TOURNAMENT_NM = input$join_tournament,
                             GAME_ID =  free_game_id(input$join_tournament),
                             CYCLER_ID = cyclers,
                             TRACK_ID = tracK_id,
                             SLOTS_OVER_FINISH = -1,
                             LANE = -1,
                             EXHAUST_LEFT = -1)
  con <- connDB(con, "flaimme")
  dbIns("TOURNAMENT_RESULT", new_row_data, con)
  # prev_exhaust <- dbSelectAll("TOURNAMENT_RESULT", con)
  # prev_game_id <- free_game_id(input$join_tournament) - 1
  # if (prev_game_id > 0) {
  #   filter_exh <- prev_exhaust[GAME_ID == prev_game_id, .(CYCLER_ID, starting_exhaust = round(EXHAUST_LEFT / 2))]
  #
  # }


  #pre_deal cards for the betting


})



observeEvent(input$bet_for_breakaway, {
  move_to$tab <- "tab_bet_for_breakaway"
})
