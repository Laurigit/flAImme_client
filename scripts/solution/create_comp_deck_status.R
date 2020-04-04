create_comp_deck_status <- function(deck_status, team_id, ADM_CYCLER_INFO) {

  not_my_team_cyc <- ADM_CYCLER_INFO[TEAM_ID != team_id, .(CYCLER_ID, TEAM_COLOR, SHORT_TYPE)]

  rem_cards <- deck_status[Zone != "Removed" , .N, by = .(CYCLER_ID, CARD_ID)]
  rem_cards[, comb_id := ifelse(CARD_ID == 1, 2, CARD_ID)]
  joinaa <- rem_cards[not_my_team_cyc, on = "CYCLER_ID"][!is.na(comb_id)]
  dummy_row <- data.table(TEAM_COLOR = "nope", SHORT_TYPE = "delme", comb_id = c(2,3,4,5,6,7,9), N = 0)
  appendaa <- rbind(joinaa, dummy_row, fill = TRUE)
  #yritit laittaa kaikki sarakkaeet näkyviin, vaikak korteteja ei ois.

  appendaa[, C := paste0(str_sub(TEAM_COLOR, 1, 2), SHORT_TYPE)]
 casti <- dcast.data.table(appendaa, formula = C ~ comb_id, value.var = "N", fun.aggregate = sum, fill = 0)
 dummy_off <- casti[C != "nodelme"]

 #setnames(casti, c("TEAM_COLOR", "SHORT_TYPE"), c("Team", "S_R"))

  return(dummy_off)

}
