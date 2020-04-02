#tab_join_game
output$select_tournament <- renderUI({

  tounrament_list <-   unique(tournament$data[, TOURNAMENT_NM])


  selectInput(inputId = "join_tournament",
              label = "Select tournament to join",
              choices = tounrament_list)

})

output$my_name_is <- renderUI({
  req(input$join_tournament)

  name_list <- tournament$data[TOURNAMENT_NM == input$join_tournament & PLAYER_TYPE == "Human", PLAYER_NM]
  selectInput(inputId = "my_name", label = "Who am I?",
              choices = name_list)


})

observeEvent(input$save_me, {
  player_reactive$name <- input$my_name
  #find my team id
  player_reactive$tournament <- input$join_tournament
  player_reactive$team <-   max(tournament$data[PLAYER_NM == input$my_name, TEAM_ID])
  updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
})

observeEvent(input$join_tournament, {
  con <- connDB(con, "flaimme")
  mf_tn <- dbSelectAll("MOVE_FACT", con)[TOURNAMENT_NM == input$join_tournament]
  max_game <- mf_tn[, max(GAME_ID)]
  move_fact$data <- mf_tn[GAME_ID == max_game]
  player_reactive$game <- max_game

})
