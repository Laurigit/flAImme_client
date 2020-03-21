output$select_track <- renderUI({
#required_data("STG_TRACK")

  data_used <-   eR_TRACK()

  #create named list
  my_list <- data_used[, TRACK_ID]
  names(my_list) <- data_used[, TRACK_NAME]

  selectInput(inputId = "select_track",
              label = "Select track",
              choices = my_list)

})


observeEvent(input$go_to_add_track_tab, {
  updateTabItems(session, "sidebarmenu", selected = "tab_add_track")
})


observeEvent(input$save_players, {
  #CYCLER_ID, TYPE, COLOR,
  required_data(c("STG_CYCLER", "STG_CYCLER_TYPE", "STG_TEAM"))

  join_type_and_team <- STG_CYCLER[STG_CYCLER_TYPE, on = "CYCLER_TYPE_ID"]
  join_team  <- STG_TEAM[join_type_and_team, on = "TEAM_ID"]


  loop_input <- c(input$red_setup,input$blue_setup,  input$black_setup,
                  input$green_setup,input$purple_setup,input$white_setup
  )
  name_input <- c(input$red_name, input$blue_name, input$black_name,
                  input$green_name, input$purple_name, input$white_name)
  game_setup_data <- data.table(TEAM_ID = 1:6, status = "", PLAYER_NM = "")
  loop_counter <- 0

  for(loop in loop_input) {
    loop_counter <- loop_counter + 1
    game_setup_data[TEAM_ID == loop_counter, status := loop]
  }

  loop_counter <- 0
  for(loop_name in name_input) {
    loop_counter <- loop_counter + 1
    game_setup_data[TEAM_ID == loop_counter, PLAYER_NM := loop_name]
  }



  join_status <- game_setup_data[join_team, on = "TEAM_ID"]
  join_status[, UI_text :=  paste0(TEAM_COLOR, "-", CYCLER_TYPE_NAME)]
  join_status[, TOURNAMENT_NM := input$game_name]


  filter <- join_status[status != "Not playing"]
  sscols_to_db <- filter[, .(TOURNAMENT_NM, TEAM_ID, PLAYER_TYPE = status, PLAYER_NM)]
  con <- connDB(con, "flaimme")
  dbWriteTable(con, "TOURNAMENT", sscols_to_db, append = TRUE, row.names = FALSE)

  tournament$data <- dbSelectAll("TOURNAMENT", con)
    #save game to db
  #TOURNAMENT_ID, PLAYER_NM, PLAYER_TYPE, TEAM_ID
  updateTabItems(session, "sidebarmenu", selected = "tab_join_game")
})

# eR_TRACK_SELECTED <- eventReactive(input$select_track, {
#   required_data("STG_TRACK")
#   curren
# })



