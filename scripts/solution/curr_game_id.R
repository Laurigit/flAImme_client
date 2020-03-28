curr_game_id <- function(tn_name_input, con) {
  tres <- dbSelectAll("TOURNAMENT_RESULT", con)
  free_id <- tres[TOURNAMENT_NM == tn_name_input, max(GAME_ID)]
  if (is.infinite(free_id)) {
    free_id <- 1
  }
  return(free_id)
}
