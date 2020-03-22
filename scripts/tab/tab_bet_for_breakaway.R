#tab_bet_for_breakaway
observeEvent(input$confirm_better, {
  #tell server who is betting
browser()
  con <- connDB(con, "flaimme")

  find_cycler_id <- ADM_CYCLER_INFO[TEAM_ID ==  player_reactive$team & CYCLER_TYPE_ID == input$which_cycler_to_bet, CYCLER_ID]
  ins_row <- data.table(TOURNAMENT_NM = input$join_tournament,
                        TEAM_ID = player_reactive$team,
                        CYCLER_ID = find_cycler_id,
                        GAME_ID = free_game_id(input$join_tournament, con),
                        FIRST_BET = 0,
                        SECOND_BET = 0)


  dbIns("BREAKAWAY_BET",
        ins_row,
        con)
  #server deals cards
  #show options to human
})

breakaway_cards <- reactive({
 ########DEP
   input$confirm_better
  input$save_betted_card
  ###########

  con <- connDB(con, "flaimme")
  bet_data <- dbSelectAll("BREAKAWAY_BET_CARDS", con)
  who_is_betting <- dbSelectAll("BREAKAWAY_BET", con)[TEAM_ID == player_reactive$team]
  #check if we have a better

  if (nrow(who_is_betting) > 0) {
  my_cycler <- who_is_betting[TEAM_ID == player_reactive$team, CYCLER_ID]


  # #check if we have already chosen first card
   bet_phase <- 1
  if (who_is_betting[, FIRST_BET] > 0) {
    bet_phase <- 2
  }
   my_cards <- bet_data[order(CARD_ID)][CYCLER_ID == my_cycler & HAND_NUMBER == bet_phase, CARD_ID]
  my_cards
  } else {
    ers <- NULL
    ers
  }
})

output$breakaway_options <- renderUI({
fluidPage(
 fluidRow(actionButton(inputId = "save_betted_card", label = "Confirm")),

  fluidRow(radioGroupButtons(inputId = "break_away_buttons", label = "NULL",
                             choices = breakaway_cards()
                             ))
)
})
