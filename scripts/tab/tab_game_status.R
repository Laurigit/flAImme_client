#tab_game_status
output$players <-  renderDataTable({
  #who is playing
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

    # fluidRow(
    #   lapply(cycler_info[, CYCLER_ID], function(cyc_id) {
    #     br_color <- cycler_info[CYCLER_ID == cyc_id, UI_COLOR]
    #     short <- cycler_info[CYCLER_ID == cyc_id, SHORT_TYPE]
    #   column(1, valueBox(value = short, subtitle = NULL, color = br_color, width = NULL))
    #
    #   })
    #
    # )


}, options = list(
  paging = FALSE,
  searching = FALSE,
  info = FALSE,
  rowCallback = DT::JS(
    'function(row, data) {
    // Bold cells for those >= 5 in the first column
    if (parseFloat(data[0]) == 1)
    $("td", row).css("background", "Red");
     if (parseFloat(data[0]) == 2)
    $("td", row).css("background", "DodgerBlue");
      if (parseFloat(data[0]) == 3)
    $("td", row).css("background", "Black");}')

), rownames = FALSE)
