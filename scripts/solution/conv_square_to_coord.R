#convert cyc_square to track_piece_coordinage
conv_square_to_coord <- function(game_status, ADM_TRACK_INFO) {
  squares <- game_status[CYCLER_ID > 0, .(CYCLER_ID, SQUARE_ID)]
  joinaa <- ADM_TRACK_INFO[squares, on = "SQUARE_ID"][, .(CYCLER_ID, COORD, TRACK_PIECE_COLOR_GAME)]
  return(joinaa)


}
