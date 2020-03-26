create_track_status_map <- function(track_data, cycler_id, max_lanes) {

  my_slot <- track_data[CYCLER_ID == cycler_id, GAME_SLOT_ID]
  track_data[, SLOT_Y_AXIS := GAME_SLOT_ID - my_slot + 0.5]

  p1 <- ggplot(track_data,
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
