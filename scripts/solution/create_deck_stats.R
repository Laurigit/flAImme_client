create_deck_stats <- function(deck_status, cycler_id) {


  cykdeck <- deck_status[CYCLER_ID == cycler_id]

  res <- dcast.data.table(cykdeck, formula = CARD_ID ~ Zone, value.var = "CYCLER_ID")
  nice_cols <- res[, .(Crd = CARD_ID, Dck = Deck, Rec = Recycle, Rem = Removed)]
  return(nice_cols)

}
