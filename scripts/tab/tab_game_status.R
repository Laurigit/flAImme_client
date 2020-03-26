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

  sscols_info <- join_names[order(CYCLER_ID)][, .(Player = PLAYER_NM, Team = TEAM_COLOR, Rider = SHORT_TYPE, Position = COORD)]
  datatable(sscols_info,  rownames = FALSE, options = list(info = FALSE, paging = FALSE, dom = 't',ordering = F)) %>% formatStyle(
    'Team',
    target = 'row',
    color = styleEqual(c("Red", "Blue", "Green", "Black", "White", "Purple"), c("white", "white", "white", "white", "black", "black")),
    backgroundColor = styleEqual(c("Red", "Blue", "Green", "Black", "White", "Purple"), c('red', 'blue', 'green', 'black', 'white', 'pink'))
  )
})





output$game_map_both <- renderPlot({



  my_cycler <- ADM_CYCLER_INFO[TEAM_ID == player_reactive$team & CYCLER_TYPE_NAME == "Rouler", CYCLER_ID]

p1 <- create_track_status_map(my_cycler, ADM_CYCLER_INFO, game_status())



  my_cycler <- ADM_CYCLER_INFO[TEAM_ID == player_reactive$team & CYCLER_TYPE_NAME == "Sprinteur", CYCLER_ID]

  p2 <- create_track_status_map(my_cycler, ADM_CYCLER_INFO, game_status())


  grid.arrange(p1, p2, nrow = 1, ncol = 2)

})
