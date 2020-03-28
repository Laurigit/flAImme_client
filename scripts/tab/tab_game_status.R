# #tab_game_status


output$players <-  renderDataTable({

  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  cycler_info <- ADM_CYCLER_INFO[CYCLER_ID %in% tn_data[, CYCLER_ID]]
  cycler_info

  #create game status

  track <- tn_data[LANE == -1, max(TRACK_ID)]

  #game_status_local <- create_game_status_from_simple(game_status(), track, STG_TRACK, STG_TRACK_PIECE)
  #get cycler position
  track_info <- create_track_ui_info(STG_TRACK, STG_TRACK_PIECE, track)
  coords <- conv_square_to_coord(game_status(), track_info)
  sscols_coords <- coords[, .(CYCLER_ID, COORD)]
  sscols_coords

  cycler_names <-tournament$data[,. (TEAM_ID, PLAYER_NM)]

  join_info <- ADM_CYCLER_INFO[sscols_coords, on = "CYCLER_ID"]
  join_names <- cycler_names[join_info, on = "TEAM_ID"]


  gs_local <- game_status_simple_current_game()

  turni_used <- gs_local[, max(TURN_ID)]
  if (turni_used > 0) {

  posits_prev <- create_game_status_from_simple(gs_local[TURN_ID == (turni_used - 1)],
                                                track,
                                                STG_TRACK,
                                                STG_TRACK_PIECE
                                                )[CYCLER_ID > 0, .(GSID_OLD = GAME_SLOT_ID, CYCLER_ID)]
  posits_after <- create_game_status_from_simple(gs_local[TURN_ID == (turni_used )],
                                                 track,
                                                 STG_TRACK,
                                                 STG_TRACK_PIECE
                                                 )[CYCLER_ID > 0, .(GAME_SLOT_ID, CYCLER_ID)]
  joinaa <- posits_prev[posits_after, on = "CYCLER_ID"]
  joinaa[, MOVEMENT_GAINED := GAME_SLOT_ID - GSID_OLD]

  prev_actions_turn <- move_fact$data[TURN_ID == turni_used, .(CYCLER_ID, CARD_PLAYED = CARD_ID)]

 ex_before <-  deck_status_curr_game()[CARD_ID == 1 & HAND_OPTIONS == 1 & TURN_ID == turni_used, .(EXH_BEFORE = .N), by = .(CYCLER_ID)]
 ex_after <-  deck_status_curr_game()[CARD_ID == 1 & HAND_OPTIONS == 0 & TURN_ID == turni_used, .(EXH_AFTER = .N), by = .(CYCLER_ID)]

 joinaa_ex <- ex_before[ex_after, on = "CYCLER_ID"]
 joinaa_ex[is.na(EXH_BEFORE), EXH_BEFORE := 0]
 joinaa_ex[, EX_GAINED := EXH_AFTER - EXH_BEFORE]

  join_ex_to_names <- joinaa_ex[join_names, on = "CYCLER_ID"]
  join_acts <- prev_actions_turn[join_ex_to_names, on = "CYCLER_ID"]
  join_move <-joinaa[join_acts, on = "CYCLER_ID"]

  sscols_info <- join_move[order(CYCLER_ID)][, .(Player = PLAYER_NM, Team = TEAM_COLOR, Rider = SHORT_TYPE, Position = COORD, Played = CARD_PLAYED,
                                                 Moves = MOVEMENT_GAINED,
                                                 Exhaust = EX_GAINED
                                                 )]

  datatable(sscols_info,  rownames = FALSE, options = list(info = FALSE, paging = FALSE, dom = 't',ordering = F)) %>% formatStyle(
    'Team',
    target = 'row',
    color = styleEqual(c("Red", "Blue", "Green", "Black", "White", "Purple"), c("white", "white", "white", "white", "black", "black")),
    backgroundColor = styleEqual(c("Red", "Blue", "Green", "Black", "White", "Purple"), c('red', 'blue', 'green', 'black', 'white', 'pink'))
  )
  }
})





output$game_map_both <- renderPlot({



  my_cycler <- ADM_CYCLER_INFO[TEAM_ID == player_reactive$team & CYCLER_TYPE_NAME == "Rouler", CYCLER_ID]

p1 <- create_track_status_map(my_cycler, ADM_CYCLER_INFO, game_status())



  my_cycler <- ADM_CYCLER_INFO[TEAM_ID == player_reactive$team & CYCLER_TYPE_NAME == "Sprinteur", CYCLER_ID]

  p2 <- create_track_status_map(my_cycler, ADM_CYCLER_INFO, game_status())


  grid.arrange(p1, p2, nrow = 1, ncol = 2)

})





