#tab_human_input

observeEvent(input$show_map, {
  updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
})

output$players <-  renderDataTable({

  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  cycler_info <- ADM_CYCLER_INFO[CYCLER_ID %in% tn_data[, CYCLER_ID]]
  cycler_info

  #create game status

  track <- tn_data[LANE == -1, max(TRACK_ID)]

  #game_status_local <- create_game_status_from_simple(game_status(), track, STG_TRACK, STG_TRACK_PIECE)
  #get cycler position
  track_info <- create_track_ui_info(STG_TRACK, STG_TRACK_PIECE, 1)
  coords <- conv_square_to_coord(game_status(), track_info)
  sscols_coords <- coords[, .(CYCLER_ID, COORD)]
  sscols_coords

  cycler_names <- tournament$data[,. (TEAM_ID, PLAYER_NM)]

  join_info <- ADM_CYCLER_INFO[sscols_coords, on = "CYCLER_ID"]
  join_names <- cycler_names[join_info, on = "TEAM_ID"]


  gs_local <- game_status_simple_current_game()

  turni_used <- gs_local[, max(TURN_ID)]
  if (turni_used > 0) {

    posits_prev <- create_game_status_from_simple(gs_local[TURN_ID == (turni_used - 1)],
                                                  track,
                                                  STG_TRACK,
                                                  STG_TRACK_PIECE
    )[CYCLER_ID > 0, .(GSID_OLD = GAME_SLOT_ID, CYCLER_ID)]
    posits_after <- create_game_status_from_simple(gs_local[TURN_ID == (turni_used )],
                                                   track,
                                                   STG_TRACK,
                                                   STG_TRACK_PIECE
    )[CYCLER_ID > 0, .(GAME_SLOT_ID, CYCLER_ID)]
    joinaa <- posits_prev[posits_after, on = "CYCLER_ID"]
    joinaa[, MOVEMENT_GAINED := GAME_SLOT_ID - GSID_OLD]

    prev_actions_turn <- move_fact$data[TURN_ID == turni_used, .(CYCLER_ID, CARD_PLAYED = CARD_ID)]

    ex_before <-  deck_status_curr_game()[CARD_ID == 1 & HAND_OPTIONS == 1 & TURN_ID == turni_used, .(EXH_BEFORE = .N), by = .(CYCLER_ID)]
    ex_after <-  deck_status_curr_game()[CARD_ID == 1 & HAND_OPTIONS == 0 & TURN_ID == turni_used, .(EXH_AFTER = .N), by = .(CYCLER_ID)]

    joinaa_ex <- ex_before[ex_after, on = "CYCLER_ID"]
    joinaa_ex[is.na(EXH_BEFORE), EXH_BEFORE := 0]
    joinaa_ex[, EX_GAINED := EXH_AFTER - EXH_BEFORE]

    join_ex_to_names <- joinaa_ex[join_names, on = "CYCLER_ID"]
    join_acts <- prev_actions_turn[join_ex_to_names, on = "CYCLER_ID"]
    join_move <-joinaa[join_acts, on = "CYCLER_ID"]

    sscols_info <- join_move[order(CYCLER_ID)][, .(C = paste0(str_sub(TEAM_COLOR, 1, 3),SHORT_TYPE), Pos = COORD, Crd = CARD_PLAYED,
                                                   Mv = MOVEMENT_GAINED,
                                                   Ex = EX_GAINED
    )]

    datatable(sscols_info,  rownames = FALSE, options = list(scrollX = TRUE, autoWidth = FALSE,
                                                              columnDefs = list(list(width = '1px', targets = "_all")),
                                                              info = FALSE,
                                                              paging = FALSE, dom = 't',ordering = F)) %>% formatStyle(
      'C',
      target = 'row',
      color = styleEqual(c("RedR", "BluR", "GreR", "BlaR", "WhiR", "PurR", "RedS", "BluS", "GreS", "BlaS", "WhiS", "PurS"), c("white", "white", "white", "white", "black", "black", "white", "white", "white", "white", "black", "black")),
      backgroundColor = styleEqual(c("RedR", "BluR", "GreR", "BlaR", "WhiR", "PurR", "RedS", "BluS", "GreS", "BlaS", "WhiS", "PurS"), c('red', 'blue', 'green', 'black', 'white', 'pink', 'red', 'blue', 'green', 'black', 'white', 'pink'))
    ) %>% formatStyle(columns = c(1,2,3,4,5), width='1px')
  }
})
observeEvent(input$select_played_card, {
  if (is.null(input$confirm_selected_card)) {
    shinyjs::disable("confirm_selected_card")
  } else {
    shinyjs::enable("confirm_selected_card")
  }
})


observeEvent(input$confirm_selected_card, {
  #save to db, update ui
  con <- connDB(con, "flaimme")
  played_card <- input$select_played_card

  if (played_card_status() == 2) {
    play_first <- 1
  }  else if (played_card_status() == 3) {
    play_first <- 0
  }
  turni <- get_current_turn(input$join_tournament, game_status_simple_current_game(), con)
  dbQ(paste0('update MOVE_FACT set CARD_ID = ', played_card,  ' where TEAM_ID = ',player_reactive$team, ' AND TOURNAMENT_NM = "', input$join_tournament, '"
  AND TURN_ID = ', turni, ' AND FIRST_SELECTED = ', play_first), con)

  move_fact$data <- dbSelectAll("MOVE_FACT", con)[GAME_ID == player_reactive$game & TOURNAMENT_NM == input$join_tournament]
  updateSelectInput(session, inputId = "select_played_card", selected = NULL)
  shinyjs::disable("confirm_selected_card")
})





con <- connDB(con, "flaimme")


played_card_status <- reactive({
  req(input$join_tournament)
    req( move_fact$data)
    req(player_reactive$team)

    if (nrow(game_status_simple_current_game()) > 0) {
     print("played_card_status_react")

  #check if we are waiting for others to finish
  gid <- curr_game_id(input$join_tournament, con)
  mf_curr_game <- move_fact$data[TOURNAMENT_NM == input$join_tournament & GAME_ID == gid]
  played_total <- mf_curr_game[CARD_ID > 0, .N]

  #check how many moves I need to make this turn in case I am finished
  cyclers_left_total <- game_status_simple_current_game()[CYCLER_ID > 0, CYCLER_ID]
  missing_total <- length(cyclers_left_total) - played_total

  cyclers_left <- ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left_total & TEAM_ID == player_reactive$team, .N]
  current_turn <- get_current_turn(input$join_tournament, game_status_simple_current_game(), con)
  # #count cards waiting to be played
   count_cards_waiting <- mf_curr_game[TEAM_ID == player_reactive$team & CARD_ID < 0, .N]
   how_many_played <-  mf_curr_game[TEAM_ID == player_reactive$team & CARD_ID > 0  & TURN_ID == current_turn, .N]
   first_cycler_selected <- mf_curr_game[TEAM_ID == player_reactive$team & TURN_ID == current_turn , .N] > 0

   if (cyclers_left  == 0) {
     status <- 4
   } else if (current_turn > 0 & first_cycler_selected == FALSE) {
    #I need to choose cycler

     status <- 1
   }  else if (how_many_played == 0) {
     # i need to choose first card
       status <- 2
     } else if (how_many_played == 1 & count_cards_waiting == 1) {
       #i need to choose 2nd card
      status <- 3
     } else if (missing_total > 0) {


       status <- 4
     } else {
       status <- 5
     }

return(status)
    }
})

observeEvent(played_card_status(), {

  session$sendCustomMessage(type = "scrollCallback", 1)
})

output$act_button_continue <- renderUI({
  actionBttn(inputId = "continue_to_game_status_from_select_card",
             label = "Continue",
             style = "material-flat",
             size = "lg",
             block = TRUE)
})

observeEvent(input$continue_to_game_status_from_select_card,{
  updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
})



output$rouler_deck <- DT::renderDataTable({
  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
  if (turni > 1) {
  choices_input <- choices_input_all[TURN_ID == (turni - 1) & HAND_OPTIONS == 0]
  cycler_input <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == "Rouler" & TEAM_ID == player_reactive$team, CYCLER_ID]
  resdata <- create_deck_stats(choices_input, cycler_input)
  resdt <- datatable(resdata,  caption = "Rouler",  rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE, dom = 't',ordering = F))
  }
  })

output$sprinter_deck <- DT::renderDataTable({
  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
  if (turni > 1) {
  choices_input <- choices_input_all[TURN_ID == (turni - 1) & HAND_OPTIONS == 0]
  cycler_input <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == "Sprinteur" & TEAM_ID == player_reactive$team, CYCLER_ID]
  resdata <- create_deck_stats(choices_input, cycler_input)
  resdt <- datatable(resdata, caption = "Sprinteur", rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE,
                                                                                      dom = 't',ordering = F)) %>% formatStyle(columns = c(1,2,3,4,5), width='1px')
  }
  })

output$other_decks <- DT::renderDataTable({
  choices_input_all <- deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ]
  cycler_options <- move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1]

  turni <- choices_input_all[, max (TURN_ID)]
 if (turni >= 1) {
   choices_input <- choices_input_all[TURN_ID == (turni - 1) & HAND_OPTIONS == 0]

  resdata <- create_comp_deck_status(choices_input, player_reactive$team, ADM_CYCLER_INFO)
  resdt <- datatable(resdata,  rownames = FALSE, options = list(scrollX=TRUE , info = FALSE,
                                                                                      paging = FALSE,
                                                                                      dom = 't',ordering = F)) %>% formatStyle(
                                                                                        colnames(resdata)[2:ncol(resdata)],
                                                                                        target = 'cell',
                                                                                        color = "black",
                                                                                        backgroundColor = styleEqual(c(1, 2, 3, 0), c("orange", "yellow", "green", "red")
                                                                                        )
                                                                                      ) %>% formatStyle(columns = c(1,2,3,4,5,6,7,8,9), width='1px') %>% formatStyle(
    'C',
    target = 'row',
    color = styleEqual(c("RedR", "BluR", "GreR", "BlaR", "WhiR", "PurR", "RedS", "BluS", "GreS", "BlaS", "WhiS", "PurS"), c("white", "white", "white", "white", "black", "black", "white", "white", "white", "white", "black", "black")),
    backgroundColor = styleEqual(c("RedR", "BluR", "GreR", "BlaR", "WhiR", "PurR", "RedS", "BluS", "GreS", "BlaS", "WhiS", "PurS"), c('red', 'blue', 'green', 'black', 'white', 'pink', 'red', 'blue', 'green', 'black', 'white', 'pink'))
  )#%>%DT::formatStyle(columns = c(1,2,3,4,5,6,7,8,9), fontSize = '50%')

 }
})

