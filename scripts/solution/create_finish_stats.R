
create_finish_stats <- function(tn_data) {

  ordered <- tn_data[order(GAME_ID, FINISH_TURN, -SLOTS_OVER_FINISH, LANE)]
  ordered[, finish_ranking := seq_len(.N), by = GAME_ID]
  ordered[, individual_time := FINISH_TURN * 60 + (5 - SLOTS_OVER_FINISH) * 10]
  ordered[, adjusted_time := as.double(NA)]
  #if you trailing right behind, you get the same time

  game_id_loop <- tn_data[, .N, by = .(GAME_ID)][, GAME_ID]
  for (game_loop in game_id_loop) {
    position_loop <- ordered[GAME_ID == game_loop, finish_ranking]
    for (pos_loop in position_loop) {
      my_finish_slot <- ordered[GAME_ID == game_loop & pos_loop == finish_ranking, SLOTS_OVER_FINISH]
      my_finish_turn <- ordered[GAME_ID == game_loop & pos_loop == finish_ranking, FINISH_TURN]
      my_finish_time <- ordered[GAME_ID == game_loop & pos_loop == finish_ranking, individual_time]
      #check if one ahead was occupied

      count_cyclers <- ordered[GAME_ID == game_loop & SLOTS_OVER_FINISH == (my_finish_slot + 1) & FINISH_TURN == my_finish_turn, .N]
      count_cyclers
      if (count_cyclers > 0) {

        ordered[GAME_ID == game_loop & finish_ranking == pos_loop, adjusted_time := prev_cycler_time]
      }
      prev_cycler_time <- my_finish_time
    }
  }

  ordered[, bonus_seconds := ifelse(finish_ranking <= 2, -10, 0)]
  ordered[, team_points := pmax(0, 4 - finish_ranking)]
  ordered[, fix_na_time := ifelse(is.na(adjusted_time), individual_time, adjusted_time)]
  ordered[, final_time := fix_na_time + bonus_seconds]
  ordered[, best_time := min(final_time), by = GAME_ID]
  sscols <- ordered[,. (GAME_ID, CYCLER_ID, POINTS = team_points, TIME = final_time - best_time)]
  return(sscols)
}
