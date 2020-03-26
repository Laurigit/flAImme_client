create_track_status_map <- function(cycler_id, ADM_CYCLER_INFO, game_status) {

  cycler_pos <- game_status[, .(LANE_graph = 4- LANE_NO, GAME_SLOT_ID, PIECE_ATTRIBUTE, CYCLER_ID, LANE_NO)]


  cyc_type <- ADM_CYCLER_INFO[, .(SHORT_TYPE, CYCLER_ID)]
  joinaa <- cyc_type[cycler_pos, on = "CYCLER_ID"]



  color_mapping_table <- data.table(CYCLER_ID = c(0,1,2,3,4,5,6,7,8,9,10,11,12),
                                    color_id = c(9,1,1,2,2,3,3,4,4,5,5,6,6),
                                    font_color = c(9,6,6,6,6,6,6,6,6,3,3,3,3))
  piece_attribute_map <- data.table(PIECE_ATTRIBUTE  = c("N", "M", "A", "C", "S"),
                                    pa_color = c(6, 1, 11, 7, 8))


  join_colors <- color_mapping_table[joinaa, on = "CYCLER_ID"]
  join_pa_map <- piece_attribute_map[join_colors, on = "PIECE_ATTRIBUTE"]

  #dont shoe more lanes than needed

  finish_slot <- game_status[FINISH == 1, max(GAME_SLOT_ID)]
  start_slot <- game_status[START == 1, max(GAME_SLOT_ID)]
  join_pa_map[, pa_color_with_finish := ifelse(GAME_SLOT_ID <= start_slot | GAME_SLOT_ID >= finish_slot, 10, pa_color)]
  max_lanes <- game_status[GAME_SLOT_ID <= finish_slot, max(LANE_NO)]
  filter_lanes <- join_pa_map[LANE_NO <= max_lanes]
  my_slot <- filter_lanes[CYCLER_ID == cycler_id, GAME_SLOT_ID]
  filter_lanes[, SLOT_Y_AXIS := GAME_SLOT_ID - my_slot + 0.5]

  p1 <- ggplot(filter_lanes,
               aes(x = LANE_graph, y = SLOT_Y_AXIS, fill = factor(color_id))) +
    #geom_tile(color = "gray", size = 5) +
    geom_tile(aes( color=as.factor(pa_color_with_finish), width = 1, height = 1), size=2) +
    geom_text(aes(label = SHORT_TYPE, color = as.factor(font_color)), size = 10) +
    scale_fill_manual(values=c("1" = "red",
                               "2" = "blue3",
                               "3" = "black",
                               "4" =" green",
                               "5" = "pink",
                               "6" = "white",
                               "7" = "brown",
                               "8" = "deepskyblue1",
                               "9" = "grey",
                               "10" = "yellow",
                               "11" = "blue"))+
    scale_color_manual(values=c("1" = "red",
                                "2" = "blue3",
                                "3" = "black",
                                "4" ="green",
                                "5" = "pink",
                                "6" = "white",
                                "7" = "brown",
                                "8" = "deepskyblue1",
                                "9" = "grey",
                                "10" = "yellow",
                                "11" = "blue"))+
    theme(axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x=element_blank(),
          legend.position = "none"
    ) +
    scale_x_continuous(limits = c(3.5 - max_lanes ,3.5), expand = c(0, 0)) +

    scale_y_continuous(limits = c(0,10), expand = c(0, 0), breaks = c(0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5),
                       label = c(0, 1,2,3, 4, 5, 6, 7, 8, 9))
  return(p1)
}
