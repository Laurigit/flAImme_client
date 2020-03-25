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
  datatable(sscols_info,  rownames = FALSE, options = list(info = FALSE, paging = FALSE)) %>% formatStyle(
    'Team',
    target = 'row',
    color = styleEqual(c("Red", "Blue", "Green", "Black", "White", "Purple"), c("white", "white", "white", "white", "black", "black")),
    backgroundColor = styleEqual(c("Red", "Blue", "Green", "Black", "White", "Purple"), c('red', 'blue', 'green', 'black', 'white', 'pink'))
  )
})

output$game_map <- renderPlot({

  #CYCLER_TYPE, PIECE_ATTRIBUTE, X = LANE, Y = GAME_SLOT_ID, Z = TEAM_COLOR
  ADM_CYCLER_INFO
  cycler_pos <- game_status()[CYCLER_ID > 0, .(LANE_graph = 4- LANE_NO, GAME_SLOT_ID, PIECE_ATTRIBUTE, CYCLER_ID)]
  my_cycler <- 1
  my_slot <- cycler_pos[CYCLER_ID == my_cycler, GAME_SLOT_ID]
  cycler_pos[, SLOT_Y_AXIS := GAME_SLOT_ID - my_slot + 1]
  cyc_type <- ADM_CYCLER_INFO[, .(SHORT_TYPE, CYCLER_ID)]
  joinaa <- cyc_type[cycler_pos, on = "CYCLER_ID"]


  scale_fill_rider_background <- function() {
   manual_scale(
      aesthetics = 'taustavari',
      value = setNames(c("red", "blue", "black", "green", "pink", "white"),
                       c(1, 2, 3, 4, 5, 6))
    )
  }

  colors <- c("red", "blue", "black", "green", "pink", "white", "brown", "deepskyblue1", "grey")
  color_map <- c("1" = "red",
                "2" = "blue",
                "3" = "black",
                "4" ="green",
                "5" = "pink",
                "6" = "white",
                "7" = "brown",
                "8" = "deepskyblue1",
                "9" = "grey")
  color_mapping_table <- data.table(CYCLER_ID = c(1,2,3,4,5,6,7,8,9,10,11,12),
                                    color_id = c(1,1,2,2,3,3,4,4,5,5,6,6),
                                    font_color = c(6,6,6,6,6,6,6,6,3,3,3,3))
  piece_attribute_map <- data.table(PIECE_ATTRIBUTE  = c("N", "M", "A", "C", "S"),
                                    pa_color = c(9, 1, 2, 7, 8))


  join_colors <- color_mapping_table[joinaa, on = "CYCLER_ID"]
join_pa_map <- piece_attribute_map[join_colors, on = "PIECE_ATTRIBUTE"]
print(join_pa_map)
  p1 <- ggplot(join_pa_map,
             aes(x = LANE_graph, y = SLOT_Y_AXIS, fill = factor(color_id))) +
  #geom_tile(color = "gray", size = 5) +
  geom_tile(aes( color=as.factor(pa_color), width=0.9, height=0.9), size=2) +
  geom_text(aes(label = SHORT_TYPE, color = as.factor(font_color)), size = 10) +
    scale_fill_manual(values=c("1" = "red",
                               "2" = "blue",
                               "3" = "black",
                               "4" ="green",
                               "5" = "pink",
                               "6" = "white",
                               "7" = "brown",
                               "8" = "deepskyblue1",
                               "9" = "grey"))+
    scale_color_manual(values=c("1" = "red",
                                "2" = "blue",
                                "3" = "black",
                                "4" ="green",
                                "5" = "pink",
                                "6" = "white",
                                "7" = "brown",
                                "8" = "deepskyblue1",
                                "9" = "grey"))
    # scale_colour_manual(
    #   values = color_map,
    #   aesthetics = c("colour", "fill")
    # )

plot(p1)

})
