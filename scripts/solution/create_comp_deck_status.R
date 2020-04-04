create_comp_deck_status <- function(deck_status, team_id, ADM_CYCLER_INFO) {

  not_my_team_cyc <- ADM_CYCLER_INFO[TEAM_ID != team_id, .(CYCLER_ID, TEAM_COLOR, CYCLER_TYPE_NAME)]

  rem_cards <- deck_status[Zone != "Removed" , .N, by = .(CYCLER_ID, CARD_ID)]
  joinaa <- rem_cards[not_my_team_cyc, on = "CYCLER_ID"][!is.na(CARD_ID)]
  dummy_row <- data.table(TEAM_COLOR = "nope", CYCLER_TYPE_NAME = "delme", CARD_ID = c(1,2,3,4,5,6,7,9), N = 0)
  appendaa <- rbind(joinaa, dummy_row, fill = TRUE)
  #yritit laittaa kaikki sarakkaeet näkyviin, vaikak korteteja ei ois.


 casti <- dcast.data.table(appendaa, formula = TEAM_COLOR + CYCLER_TYPE_NAME~ CARD_ID, value.var = "N", fun.aggregate = sum, fill = 0)

 setnames(casti, c("TEAM_COLOR", "CYCLER_TYPE_NAME"), c("Team", "Cycler"))
 dummy_off <- casti[Team != "nope"]
  return(dummy_off)

}
