# #tab_bet_for_breakaway
#


breakaway_bets_data <- reactive({
  print("reactive breakaway_bets_data")
  #dep
  update_breakaway_bet$data
  ##########3
  con <- connDB(con, "flaimme")
  res <- dbQ('SELECT * from BREAKAWAY_BET', con)
  res

})

#betting <- reactiveValues(phase = NULL)
ui_control <- reactiveValues(table = FALSE,
                             confirm = FALSE,
                             cards = FALSE,
                             done = FALSE,
                             input_hand_number = 0)
betting_phase <- reactive({
  print("reactive betting_phase")
req(player_reactive$team)

#phases
  #0 I have not selected participant
  #1 I have not selectet firs card. Show card options
  #1.5 I have selected my first card, others not. Show next options, don't let save
  #2 Everyone has selected first card. Show table with First played. Allow playing second card
  #3 I have played by second card, show full table
  #4 EVERYone ready, execute
    ###########
  input$join_tournament
  input$save_betted_card

  breakaway_bets_data2()
  #########
  who_is_betting <-   breakaway_bets_data()[TEAM_ID == player_reactive$team & GAME_ID ==  curr_game_id(input$join_tournament, con)]
  #check if we have a better
  bet_phase <- 0

  if (nrow(who_is_betting) > 0) {
    bet_phase <- 1
    my_cycler <- who_is_betting[TEAM_ID == player_reactive$team, CYCLER_ID]


    # #check if we have already chosen first card

    if (who_is_betting[, FIRST_BET] > 0) {

      bet_phase <- 1.5
    #check if everyone else have bet
      count_teams <- tournament$data[TOURNAMENT_NM == input$join_tournament, uniqueN(TEAM_ID)]
      ba_data <- breakaway_bets_data()[TOURNAMENT_NM == input$join_tournament  & GAME_ID == curr_game_id(input$join_tournament, con)]
      unplayed_count <- count_teams - ba_data[FIRST_BET > 0, .N]
      if (unplayed_count == 0) {
        bet_phase <- 2
        #check if I have played second card
        if (who_is_betting[, SECOND_BET] > 0) {
          bet_phase <- 3
          #check if everyone has played second
          unplayed_count_2nd <- count_teams - ba_data[SECOND_BET > 0, .N]
          if (unplayed_count_2nd == 0) {
            bet_phase <- 4
            #all done
          }
        }
      }

    }
  }
  print("BSTPHASE")
  print(bet_phase)
  bet_phase
})


output$breakaway_options <- renderUI({
  print("output betting_phase")
if (ui_control$cards) {
  my_cycler <- breakaway_bets_data()[TEAM_ID == player_reactive$team & GAME_ID == curr_game_id(input$join_tournament, con) & TOURNAMENT_NM == input$join_tournament, CYCLER_ID]
  card_choises <-  breakaway_cards()[CYCLER_ID == my_cycler & GAME_ID == curr_game_id(input$join_tournament, con) & HAND_NUMBER == ui_control$input_hand_number & TOURNAMENT_NM == input$join_tournament, CARD_ID]
  cards_label <- paste0("Hand number ", ui_control$input_hand_number,". Select card to bet")
  fluidRow(radioGroupButtons(inputId = "break_away_buttons",
                             status = "info",
                             justified = TRUE,
                             individual = TRUE,
                             checkIcon = list("yes", "no"),
                             selected = "NULL",
                             label = cards_label,
                             choices = card_choises,
                             size = "lg",
                             width = "100%"))
}

  })

observe({
  print("output breakaway_cards")

  req(breakaway_cards())

  req(breakaway_bets_data(),  input$join_tournament, player_reactive$team)

  #disable confirm unless everyone has selected first bet
  #count missing decisions
  ba_data <- breakaway_bets_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  curr_game_id(input$join_tournament, con)]
  my_bet <- ba_data[TEAM_ID == player_reactive$team, FIRST_BET]
  ui_control$confirm <- FALSE
  ui_control$cards <- FALSE
  ui_control$table <- FALSE
  #have I announce who is particitipating?
  card_choises <- c(0, 0)
  ui_control$done <- FALSE
  if (betting_phase() == 0) {
    ui_control$cards <- FALSE
    ui_control$confirm <- FALSE
    ui_control$table <- FALSE

    shinyjs::disable("save_betted_card")
    shinyjs::enable("which_cycler_to_bet")
    shinyjs::enable("confirm_better")

    ui_control$input_hand_number  <- 0
  } else if (betting_phase() == 1){
    ui_control$input_hand_number  <- 1
    ui_control$confirm <- TRUE
    ui_control$cards <- TRUE
    ui_control$table <- FALSE
    shinyjs::disable("which_cycler_to_bet")
    shinyjs::disable("confirm_better")
    shinyjs::enable("save_betted_card")
    #card choices
    #first find cycler

} else if (betting_phase() == 1.5){
  ui_control$input_hand_number <- 2
  ui_control$confirm <- FALSE
  ui_control$cards <- TRUE
  ui_control$table <- FALSE
  shinyjs::disable("which_cycler_to_bet")
  shinyjs::disable("confirm_better")
  shinyjs::disable("save_betted_card")
  #card choices
  #first find cycler
       }  else if (betting_phase() == 2) {
        ui_control$input_hand_number  <- 2
        ui_control$confirm <- TRUE
        ui_control$cards <- TRUE
        ui_control$table <- TRUE
        shinyjs::disable("which_cycler_to_bet")
        shinyjs::disable("confirm_better")
        shinyjs::enable("save_betted_card")
        #card choices
        #first find cycler
         }else  {


          ui_control$confirm <- FALSE
          ui_control$cards <- FALSE
          ui_control$table <- TRUE
          ui_control$done <- TRUE

          shinyjs::disable("which_cycler_to_bet")
          shinyjs::disable("confirm_better")
          shinyjs::disable("save_betted_card")
          #card choices
          #first find cycler
   }



})


observeEvent(input$confirm_better, {
  #tell server who is betting

  con <- connDB(con, "flaimme")

  find_cycler_id <- ADM_CYCLER_INFO[TEAM_ID ==  player_reactive$team & CYCLER_TYPE_ID == input$which_cycler_to_bet, CYCLER_ID]
  ins_row <- data.table(TOURNAMENT_NM = input$join_tournament,
                        TEAM_ID = player_reactive$team,
                        CYCLER_ID = find_cycler_id,
                        GAME_ID = curr_game_id(input$join_tournament, con),
                        FIRST_BET = 0,
                        SECOND_BET = 0)
  update_breakaway_bet$data  <- update_breakaway_bet$data + 1

  dbIns("BREAKAWAY_BET",
        ins_row,
        con)
  #server deals cards
  #show options to human
})





observeEvent(input$save_betted_card, {

  #save to db
  #update ui

  betted_card <- input$break_away_buttons
  if (!is.null(betted_card)) {
  con <- connDB(con, "flaimme")
    if (betting_phase() == 1) {
  dbQ(paste0('UPDATE BREAKAWAY_BET
      SET FIRST_BET = ', betted_card,
             ' WHERE GAME_ID = ', curr_game_id(input$join_tournament, con), ' AND TEAM_ID = ', player_reactive$team, ' AND TOURNAMENT_NM = "', input$join_tournament, '"'), con)
    } else if(betting_phase() == 2) {

      dbQ(paste0('UPDATE BREAKAWAY_BET
      SET SECOND_BET = ', betted_card,
                  ' WHERE GAME_ID = ', curr_game_id(input$join_tournament, con), ' AND TEAM_ID = ', player_reactive$team, ' AND TOURNAMENT_NM = "', input$join_tournament, '"'), con)
}
  update_breakaway_bet$data  <- update_breakaway_bet$data + 1
  }
})

output$breakaway_results <- renderTable({
  print("breakaway results output")

if (ui_control$table == TRUE) {
  req(breakaway_bets_data(),  input$join_tournament)

  #only show if decision is made
  req(player_reactive$team)
  con <- connDB(con, "flaimme")

  ba_data <- breakaway_bets_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  curr_game_id(input$join_tournament, con)]

  join_player <- tournament$data[TOURNAMENT_NM == input$join_tournament][ba_data, on = "TEAM_ID"]
  join_cycler_type <- ADM_CYCLER_INFO[join_player, on = "CYCLER_ID"]
  if (betting_phase() < 3) {
  ss_cols <- join_cycler_type[, .(PLAYER_NM, CYCLER_TYPE_NAME, FIRST_BET)]
  } else {
    ss_cols <- join_cycler_type[, .(PLAYER_NM, CYCLER_TYPE_NAME, FIRST_BET, SECOND_BET, TOTAL = FIRST_BET + SECOND_BET)][order(-TOTAL)]

  }
  ss_cols
}
})

output$betting_done <- renderUI({
if ( ui_control$done){
  actionBttn(inputId = "betting_done", label = "Ready to play", style = "material-flat", color = "success", size = "lg")
}
})

observeEvent(input$betting_done, {
  updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
})
