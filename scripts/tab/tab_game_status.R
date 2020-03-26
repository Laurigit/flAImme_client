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
  # p2 <- ggplot(filter_lanes,
  #              aes(x = LANE_graph, y = SLOT_Y_AXIS, fill = factor(color_id))) +
  #   #geom_tile(color = "gray", size = 5) +
  #   geom_tile(aes( color=as.factor(pa_color_with_finish), width = 1, height = 1), size=2) +
  #   geom_text(aes(label = SHORT_TYPE, color = as.factor(font_color)), size = 10) +
  #   scale_fill_manual(values=c("1" = "red",
  #                              "2" = "blue3",
  #                              "3" = "black",
  #                              "4" =" green",
  #                              "5" = "pink",
  #                              "6" = "white",
  #                              "7" = "brown",
  #                              "8" = "deepskyblue1",
  #                              "9" = "grey",
  #                              "10" = "yellow",
  #                              "11" = "blue"))+
  #   scale_color_manual(values=c("1" = "red",
  #                               "2" = "blue3",
  #                               "3" = "black",
  #                               "4" ="green",
  #                               "5" = "pink",
  #                               "6" = "white",
  #                               "7" = "brown",
  #                               "8" = "deepskyblue1",
  #                               "9" = "grey",
  #                               "10" = "yellow",
  #                               "11" = "blue"))+
  #   theme(axis.title.x=element_blank(),
  #         axis.title.y=element_blank(),
  #         axis.text.x = element_blank(),
  #         axis.ticks.x=element_blank(),
  #         legend.position = "none"
  #   ) +
  #   scale_x_continuous(limits = c(3.5 - max_lanes ,3.5), expand = c(0, 0)) +
  #
  #   scale_y_continuous(limits = c(0,10), expand = c(0, 0), breaks = c(0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5),
  #                      label = c(0, 1,2,3, 4, 5, 6, 7, 8, 9))

  grid.arrange(p1, p2, nrow = 1, ncol = 2)

})
