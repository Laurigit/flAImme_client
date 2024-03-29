# #tab_game_status


#
# game_status_slower <- reactiveValues(time = Sys.time(), prev_gs = NULL)
# observe({
#   #this stops UI for 5sec max after map game_status update
#   req(game_status())
#
#
#   if (is.null( game_status_slower$prev_gs)) {
#     game_status_slower$prev_gs <- game_status()
#   }
# if (game_status()[CYCLER_ID > 0, sum(GAME_SLOT_ID)] != game_status_slower$prev_gs[CYCLER_ID > 0, sum(GAME_SLOT_ID)]) {
#   duration <- difftime(Sys.time(), game_status_slower$time, units = c("secs"))
#   wait_time <- max(0, 5 - duration)
#   print(wait_time)
#   Sys.sleep(wait_time)
#   game_status_slower$time <- Sys.time()
#   game_status_slower$prev_gs <- game_status()
# }
#
# })


output$game_map_full <- renderPlot({


req( game_status())


  p1 <- create_track_status_map_FULL(ADM_CYCLER_INFO, game_status(), player_reactive$team)

  # my_cycler <- ADM_CYCLER_INFO[TEAM_ID == player_reactive$team & CYCLER_TYPE_NAME == "Sprinteur", CYCLER_ID]
  #
  # p2 <- create_track_status_map(my_cycler, ADM_CYCLER_INFO, game_status())
  #
  #
  # grid.arrange(p1, p2, nrow = 1, ncol = 2)
p1

})

output$game_map_scroll <- renderPlot({

  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  maxgame <- tn_data[, max(GAME_ID)]
  copy_tn <- copy(tn_data)[GAME_ID == maxgame]
  copy_tn[FINISH_TURN > 0, finish_score := -FINISH_TURN*1000+SLOTS_OVER_FINISH*10-LANE]
  copy_tn[FINISH_TURN > 0, FINISH_RANK := frank(finish_score)]
  finished_turn <- copy_tn[FINISH_TURN > 0, min(FINISH_TURN )]
  track_finish_slot <- game_status()[FINISH == 1, max(GAME_SLOT_ID)]
  podium_data <- copy_tn[FINISH_TURN == finished_turn, .(GAME_SLOT_ID = track_finish_slot + SLOTS_OVER_FINISH  - 1, LANE_NO = LANE, CYCLER_ID, FINISH_RANK)]
  track <- tn_data[LANE == -1, max(TRACK_ID)]
  track_info <- create_track_ui_info(STG_TRACK, STG_TRACK_PIECE, track)
  relevant_turn <- deck_status_curr_game()[HAND_OPTIONS == 0, max(TURN_ID)]
  copy_data <- copy(deck_status_curr_game()[TURN_ID >= 1 & CARD_ID == 1 & TURN_ID == relevant_turn])
  copy_data[, only_one := .N, by = .(row_id)]
  exhausted_cyclers <- copy_data[only_one == 1, CYCLER_ID]

  prev_moves <- move_fact$data[TURN_ID == relevant_turn, .(CYCLER_ID, CARD_ID)]
  gs_local <- game_status_simple_current_game()

  turni_used <- gs_local[, max(TURN_ID)]
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
  ss_movement_gained <- joinaa[, .(CYCLER_ID, MOVEMENT_GAINED)]


  p2 <- create_track_status_map_scrollable(ADM_CYCLER_INFO, game_status(), track_info, player_reactive$team, exhausted_cyclers, podium_data, prev_moves,
                                           ss_movement_gained)
  p2
})


output$select_which_cycler_plays_first <- renderUI({

  #check which cyclers I have left
  gs_data <- isolate(game_status_simple_current_game())
  max_gs_turn <- gs_data[, max(TURN_ID)]


  cyclers_left <- gs_data[TURN_ID == max_gs_turn & CYCLER_ID > 0, CYCLER_ID]
  my_options <- isolate(ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left & TEAM_ID == player_reactive$team, str_sub(CYCLER_TYPE_NAME, 1, 3)])
my_values <- isolate(ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left & TEAM_ID == player_reactive$team, CYCLER_TYPE_NAME])
splitLayout(cellWidths = c("20%", "40%", "40%"),
            actionBttn(inputId = "back_to_stats3", label = "Stats", style = "material-flat", color = "default", size = "md", block = TRUE),

                  actionBttn(inputId = "confim_first_played_cycler",
                             label = "Lock first cycler",
                             style = "material-flat",
                             color = "primary",
                             size = "md",
                             block = TRUE),
      radioGroupButtons(inputId = "radio_first_cycler",
                                       label = NULL,
                                       choiceNames  = my_options,
                                       choiceValues  = my_values,
                                       selected = -1,
                                       status = "info",
                                       direction = "horizontal",
                                       size = "normal",
                                       width = "100%"))
})




observeEvent(input$confim_first_played_cycler, {

  if(!is.null(input$radio_first_cycler)) {
  selected_cycler <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME == input$radio_first_cycler & TEAM_ID == player_reactive$team, CYCLER_ID]


  gs_data <- game_status_simple_current_game()
  max_gs_turn <- gs_data[, max(TURN_ID)]

  cyclers_left <- gs_data[TURN_ID == max_gs_turn & CYCLER_ID > 0, CYCLER_ID]

  if (selected_cycler %in% cyclers_left) {


  my_options <- ADM_CYCLER_INFO[CYCLER_ID %in% cyclers_left & TEAM_ID == player_reactive$team, .N]



  #write to db update UI
  con <- connDB(con, "flaimme")

  turni <- get_current_turn(input$join_tournament, game_status_simple_current_game(), con)
  game <- curr_game_id(input$join_tournament, con)

  write_data_first <- data.table(TOURNAMENT_NM = input$join_tournament,
                                 FIRST_SELECTED = 1,
                                 CYCLER_ID = selected_cycler,
                                 CARD_ID = -1,
                                 GAME_ID = game,
                                 TURN_ID = turni,
                                 TEAM_ID = player_reactive$team)


  if (my_options == 2) {
    second_cycler <- ADM_CYCLER_INFO[CYCLER_TYPE_NAME != input$radio_first_cycler & TEAM_ID == player_reactive$team, CYCLER_ID]
    write_data_second <- data.table(TOURNAMENT_NM = input$join_tournament,
                                    FIRST_SELECTED = 0,
                                    CYCLER_ID = second_cycler,
                                    CARD_ID = -1,
                                    TURN_ID = turni,
                                    GAME_ID = game,
                                    TEAM_ID = player_reactive$team )
  } else {
    write_data_second <- NULL
  }


  appendaa <- rbind(write_data_first, write_data_second)


  con <- connDB(con, "flaimme")
  dbWriteTable(con, "MOVE_FACT", appendaa, row.names = FALSE, append = TRUE)
  move_fact$data <- dbSelectAll("MOVE_FACT", con)[GAME_ID == player_reactive$game & TOURNAMENT_NM == input$join_tournament]
  }
  }
})

#obsever who has played
output$db_text <- renderText({

  req( game_status(), deck_status_curr_game(), input$join_tournament)
  moves_made <- move_fact$data[, .N]
  if (moves_made > 0 ) {
  #who are plyaing
  playing <- game_status()[CYCLER_ID > 0, .(CYCLER_ID, PLAYING = TRUE)]
  next_turn <- deck_status_curr_game()[, max(TURN_ID)]


  gamedata <-   move_fact$data[GAME_ID == player_reactive$game]

  #who has played
  played <- gamedata[TURN_ID == next_turn & CARD_ID > -1, .(CYCLER_ID, PLAYED = TRUE)]
  join_pp <- played[playing, on = "CYCLER_ID"][is.na(PLAYED)]
  ss_team <- ADM_CYCLER_INFO[, .(CYCLER_ID, TEAM_COLOR)]
  join_team <- ss_team[join_pp, on = "CYCLER_ID"]
  missing_teams <- join_team[, .N, by = TEAM_COLOR][, TEAM_COLOR]

 res <- paste0(missing_teams, collapse = " ")
 res
  } else {
    res <- ""
    res
  }
})


output$play_or_confirm <- renderUI({

req(played_card_status())

  shinyjs::disable("confirm_selected_card")
  if (played_card_status() == 1) {
    uiOutput("select_which_cycler_plays_first")
  } else if(played_card_status() == 2) {

    uiOutput(outputId = "select_played_card")
  } else if(played_card_status() == 3) {
    uiOutput(outputId = "select_played_card")
  } else {
    #browser()
    splitLayout(cellWidths = c("30%", "70%"),actionBttn(inputId = "back_to_stats1", label = "Stats", style = "material-flat", color = "default", size = "md", block = TRUE),
                h4(textOutput("db_text")))
  }
})

output$select_played_card <- renderUI({

  choices_input_all <- isolate(deck_status_data()[TOURNAMENT_NM == input$join_tournament & GAME_ID ==  player_reactive$game ])
  cycler_options <- isolate(move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                     TEAM_ID == player_reactive$team & CARD_ID == -1])



  turni <- choices_input_all[, max (TURN_ID)]
  choices_input <- choices_input_all[TURN_ID == turni]
  if (played_card_status() == 2) {
    moving_cycler <- cycler_options[FIRST_SELECTED == 1, CYCLER_ID]
    my_cyc_type <- ADM_CYCLER_INFO[CYCLER_ID == moving_cycler, CYCLER_TYPE_NAME]
    first_or_second <- paste0("Play ", my_cyc_type)
  } else if (played_card_status() == 3) {
    moving_cycler <- cycler_options[FIRST_SELECTED == 0, CYCLER_ID]
    #check what we played first
    first_move <-  move_fact$data[TOURNAMENT_NM == input$join_tournament &
                                    TEAM_ID == player_reactive$team & CARD_ID != -1 & TURN_ID == turni, CARD_ID]
    my_cyc_type <- ADM_CYCLER_INFO[CYCLER_ID == moving_cycler, CYCLER_TYPE_NAME]

    first_or_second <- paste0("Play ", str_sub(my_cyc_type, 1, 3), " (", first_move, ")")
  }  else ({
    # move_to$tab <- "tab_game_status"
    #updateTabItems(session, "sidebarmenu", selected = "tab_game_status")
    moving_cycler <- 0
  })

  my_type <- ADM_CYCLER_INFO[CYCLER_ID == moving_cycler, CYCLER_TYPE_NAME]

  card_options <- choices_input[CYCLER_ID == moving_cycler & Zone == "Hand", CARD_ID]
 splitLayout(cellWidths = c("20%", "40%", "40%"),
  actionBttn(inputId = "back_to_stats2", label = "Stats", style = "material-flat", color = "default", size = "md", block = FALSE),

           disabled(actionBttn(inputId = "confirm_selected_card", label = first_or_second,
                               style = "material-flat", size = "md", block = TRUE)
    ),

     radioGroupButtons(inputId = "select_played_card",
                                            label = NULL,
                                            selected = -1,
                                            status = "primary",
                                            size = "normal",
                                            direction = "horizontal",
                                            choices = card_options,
                                            width = "100%"
    )
  )

})

output$show_only_stats_button <- renderUI({
  fluidRow(
  actionBttn(inputId = "back_to_stats", label = "Stats", style = "material-flat", color = "default", size = "md", block = TRUE)
  )
})

observeEvent( input$back_to_stats3, {
  updateTabItems(session, "sidebarmenu", selected = "tab_human_input")
}, ignoreInit = TRUE, ignoreNULL = TRUE)

observeEvent(input$back_to_stats2,{

               updateTabItems(session, "sidebarmenu", selected = "tab_human_input")
             }, ignoreInit = TRUE, ignoreNULL = TRUE)
observeEvent(input$back_to_stats1, {

               updateTabItems(session, "sidebarmenu", selected = "tab_human_input")
             }, ignoreInit = TRUE, ignoreNULL = TRUE)
