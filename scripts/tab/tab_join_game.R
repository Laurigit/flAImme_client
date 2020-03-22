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

  player_reactive$team <-   max(tournament$data[PLAYER_NM == input$my_name, TEAM_ID])
})
