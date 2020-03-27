get_current_turn <- function(TOURNAMENT_NM_input, simple_gs, con) {
  game <- curr_game_id(TOURNAMENT_NM_input, con)
  prev_played_turn <- simple_gs[TOURNAMENT_NM == TOURNAMENT_NM_input & GAME_ID == game, max(TURN_ID)]
  if (prev_played_turn <= 0) {
    current_turn <- 1
  } else {
    current_turn <- prev_played_turn + 1
  }

  return(current_turn)
}
