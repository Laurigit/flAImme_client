create_track_status_map_scrollable <- function(ADM_CYCLER_INFO, game_status, track_info, team_id, exhausted_cyclers = NULL, podium_data = NULL, prev_moves = NULL) {

  finish_slot <- game_status[FINISH == 1, max(GAME_SLOT_ID)]
  max_lanes <- game_status[GAME_SLOT_ID <= finish_slot, max(LANE_NO)]
  game_status[, lanes_per_slot := max(LANE_NO), by = .(GAME_SLOT_ID)]
  if (max_lanes == 3) {
    game_status[, lane_intend := ifelse(lanes_per_slot == 3, 0, ifelse(lanes_per_slot == 2, 0.5, 1))]
  } else {
    game_status[, lane_intend := ifelse(lanes_per_slot == 2, 0, 0.5)]
  }

  cycler_pos_orig <- game_status[, .(LANE_graph = 4- LANE_NO - lane_intend, GAME_SLOT_ID, PIECE_ATTRIBUTE, CYCLER_ID, LANE_NO)]
  #browser()
  ss_pod <- podium_data[, .(PODIUM = CYCLER_ID, LANE_NO, GAME_SLOT_ID)]


  cycler_pos <- ss_pod[cycler_pos_orig, on = .(LANE_NO, GAME_SLOT_ID)]

  cycler_pos[!is.na(PODIUM), CYCLER_ID := PODIUM]
  cycler_pos[, PODIUM := NULL]
  cyc_type <- ADM_CYCLER_INFO[, .(SHORT_TYPE, CYCLER_ID, TEAM_ID)]
  joinaa <- cyc_type[cycler_pos, on = "CYCLER_ID"]



  joinaa[, text_size := ifelse(TEAM_ID == team_id, 12, 10)]
  joinaa[, text_size_exh := ifelse(TEAM_ID == team_id, 6, 6)]
  joinaa[, fontti := ifelse(TEAM_ID == team_id, "bold", "plain")]

  color_mapping_table <- data.table(CYCLER_ID = c(0,1,2,3,4,5,6,7,8,9,10,11,12),
                                    color_id = c(9,1,1,2,2,3,3,4,4,5,5,6,6),
                                    font_color = c(9,6,6,6,6,6,6,6,6,3,3,3,3))
  piece_attribute_map <- data.table(PIECE_ATTRIBUTE  = c("N", "M", "A", "C", "S"),
                                    pa_color = c(12, 1, 11, 7, 8))


  join_colors <- color_mapping_table[joinaa, on = "CYCLER_ID"]
  join_pa_map <- piece_attribute_map[join_colors, on = "PIECE_ATTRIBUTE"]

  #dont shoe more lanes than needed


  start_slot <- game_status[START == 1, max(GAME_SLOT_ID)]
  join_pa_map[, pa_color_with_finish := ifelse(GAME_SLOT_ID <= start_slot | GAME_SLOT_ID >= finish_slot, 10, pa_color)]

  first_extra_slot <- game_status[LANE_NO > 3, min(GAME_SLOT_ID)]
  filter_lanes2 <- join_pa_map[GAME_SLOT_ID < first_extra_slot]
  filter_lanes2[, SLOT_Y_AXIS := GAME_SLOT_ID]
  filter_lanes2[, EXHAUSTED := ifelse(CYCLER_ID %in% exhausted_cyclers, 'z', NA)]

  #join_prev_move
  filter_lanes <- prev_moves[filter_lanes2, on = .(CYCLER_ID)]

  aggr_slot_coord_orig <- track_info[, .N, by = .(GAME_SLOT_ID, SLOT_COORD)][, N := NULL]
  max_id_from_orig <- aggr_slot_coord_orig[, max(GAME_SLOT_ID)] + 1
continue_coords <- data.table(GAME_SLOT_ID = max_id_from_orig:(max_id_from_orig+100), SLOT_COORD = "*")
aggr_slot_coord <- rbind(aggr_slot_coord_orig, continue_coords)

   last_cycler_last <- filter_lanes[CYCLER_ID > 0, min(GAME_SLOT_ID)]
  last_visualized_slot <- filter_lanes[, max(GAME_SLOT_ID)] + 1 + last_cycler_last
  twenty_from_finish <- last_visualized_slot - 20
  first_visualized_slot <- max(1, min(last_cycler_last, twenty_from_finish))

  labels <- c(aggr_slot_coord[GAME_SLOT_ID >= first_visualized_slot & GAME_SLOT_ID < last_visualized_slot, SLOT_COORD])
  input_breaks <- c(rep((first_visualized_slot):(last_visualized_slot - 1)))

  p1 <- ggplot(filter_lanes,
               aes(x = LANE_graph, y = SLOT_Y_AXIS, fill = factor(color_id))) +
    #geom_tile(color = "gray", size = 5) +
    geom_tile(aes( color=as.factor(pa_color_with_finish), width = 1, height = 0.92), size = 1.2) +
    geom_text(aes(label = SHORT_TYPE, color = as.factor(font_color), size = text_size, fontface = fontti)) +
    geom_text(aes(hjust = -0.8, vjust = 0.7, label = EXHAUSTED, color = as.factor(font_color), size = text_size_exh, fontface = fontti)) +
    geom_text(aes(hjust = 1.8, vjust = 0.7, label = CARD_ID, color = as.factor(font_color), size = text_size_exh, fontface = fontti)) +
    scale_size(range = c(10, 12), guide = F) +#legend hidden +
    scale_fill_manual(values=c("1" = "red",
                               "2" = "blue3",
                               "3" = "black",
                               "4" =" green",
                               "5" = "pink",
                               "6" = "white",
                               "7" = "chocolate4",
                               "8" = "deepskyblue1",
                               "9" = "grey92",
                               "10" = "yellow",
                               "11" = "blue",
                               "12" = "grey47"))+
    scale_color_manual(values=c("1" = "red",
                                "2" = "blue3",
                                "3" = "black",
                                "4" ="green",
                                "5" = "pink",
                                "6" = "white",
                                "7" = "chocolate4",
                                "8" = "deepskyblue1",
                                "9" = "grey92",
                                "10" = "yellow",
                                "11" = "blue",
                                "12" = "grey47"))+
    theme(axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y = element_blank(),
          axis.text.y = element_text(size = 20, hjust = 1) ,
       #   axis.text.y = element_text(size = 10, hjust = -5),
          legend.position = "none",
          panel.background = element_rect(fill = "white", colour = "white", size = 0.5)
    ) +
    scale_x_continuous(limits = c(3.5 - max_lanes ,3.5), expand = c(0, 0)) +

    scale_y_continuous(limits = c(first_visualized_slot - 1, last_visualized_slot), expand = c(0, 0), breaks = input_breaks,
                       label = labels)

   # geom_segment(aes(x = 1.5, xend = 2.5, y = SLOT_Y_AXIS, yend = (SLOT_Y_AXIS - 5), colour = as.factor(LANE_NO), size = 10), data = filter_lanes)

  return(p1)
}
