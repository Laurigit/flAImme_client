create_deck_stats <- function(deck_status, cycler_id) {


  cykdeck <- deck_status[CYCLER_ID == cycler_id]

  res <- dcast.data.table(cykdeck, formula = CARD_ID ~ Zone, value.var = "CYCLER_ID")
  nice_cols <- res[, .(C = CARD_ID, D = Deck, R = Recycle, T = Removed)]
  return(nice_cols)

}
