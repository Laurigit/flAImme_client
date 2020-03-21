#tab_bet_for_breakaway
observeEvent(input$confirm_better, {
  #tell server who is betting
  ins_row <- data.table(TOURNAMENT_NM = input$join_tournament,
                        TEAM_ID = player_reactive$team,
                        CYCLER_TYPE_ID = which_cycler_to_bet,
                        GAME_ID = free_game_id(input$join_tournament))

  con <- connDB(con, "flaimme")

  dbIns("BREAKAWAY_BET",
        ins_row,
        con)
  #server deals cards
  #show options to human
})


output$breakaway_options <- renderUI({

  fluidRow(radioGroupButtons(inputId = "break_away_buttons", label = "NULL",
                             ))

})
