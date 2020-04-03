
luettu <- dbSelectAll("ADM_OPTIMAL_MOVES", con)

ADM_OPTIMAL_MOVES <- fix_colnames(luettu)

#available tournaments
tournament <- reactiveValues(data = dbSelectAll("TOURNAMENT", con))
tournament_result <- reactiveValues(data = dbSelectAll("TOURNAMENT_RESULT", con))

move_to <- reactiveValues(tab = "")

update_breakaway_bet <- reactiveValues(data = 0)

move_fact <- reactiveValues(data = NULL)

shinyServer(function(input, output, session) {
  con <- connDB(con, "flaimme")
  player_reactive <- reactiveValues(name = NULL,
                                    team = NULL,
                                    tournament = NULL,
                                    game = NULL)

#  js$hidehead('none')
  reactive({
    move_to$tab
   # updateTabItems(session, "sidebarmenu", selected = "tab_bet_for_breakaway")

  })


  #try to read status of breakaway bets
 #breakaway_bets_data <-  my_reactivePoll(session, "BREAKAWAY_BET", paste0('SELECT count(TEAM_ID) from BREAKAWAY_BET'), timeout = 1000, con)
 breakaway_cards <-  my_reactivePoll(session, "BREAKAWAY_BET_CARDS", paste0('SELECT * from BREAKAWAY_BET_CARDS'), timeout = 1000, con)

 game_status_simple <-  my_reactivePoll(session, "GAME_STATUS", paste0('SELECT sum(CYCLER_ID) FROM GAME_STATUS'), timeout = 1000, con)

 deck_status_data <-  my_reactivePoll(session, "DECK_STATUS", paste0('SELECT sum(CYCLER_ID) FROM DECK_STATUS'), timeout = 1000, con)

 tournament_data_reactive <- my_reactivePoll(session, "TOURNAMENT_RESULT", "SELECT * FROM TOURNAMENT_RESULT", 2000, con)

 deck_status_curr_game <- reactive({

   req(input$join_tournament)
    deck_tour <- deck_status_data()[TOURNAMENT_NM == input$join_tournament]
    find_latest_update <- deck_tour[, .N]
    game_id <- deck_tour[find_latest_update, GAME_ID]
    turn_id <- deck_tour[find_latest_update, TURN_ID]
   # hand_options <-  deck_tour[find_latest_update, HAND_OPTIONS]
    result <- deck_tour[GAME_ID == game_id]
    result
 })

observe({
  tournament_result$data <- tournament_data_reactive()
})


 game_status <- reactive({

   if (nrow(game_status_simple()) > 0) {

   tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
   #cycler_info <- ADM_CYCLER_INFO[CYCLER_ID %in% tn_data[, CYCLER_ID]]
      max_game <- tn_data[, max(GAME_ID)]
    player_reactive$game <- max_game
   #create game status

   track <- tn_data[LANE == -1, max(TRACK_ID)]
   game_id <- tn_data[LANE == -1, max(GAME_ID)]
   turni <- game_status_simple()[TOURNAMENT_NM == input$join_tournament & GAME_ID == game_id, max(TURN_ID)]
    gs_curr_turn <- game_status_simple()[TOURNAMENT_NM == input$join_tournament & GAME_ID == game_id & TURN_ID == turni]
   game_status_local <- create_game_status_from_simple(gs_curr_turn, track,  STG_TRACK, STG_TRACK_PIECE)
   } else {
     NULL
   }
 })

game_status_simple_current_game <- reactive({
 req(input$join_tournament)
   max_game <-  game_status_simple()[TOURNAMENT_NM == input$join_tournament, max(GAME_ID)]
   result <- game_status_simple()[GAME_ID == max_game]
   result
 })

  sourcelist <- data.table(polku = c(dir("./scripts/", recursive = TRUE)))
  sourcelist[, rivi := seq_len(.N)]
  suppressWarnings(sourcelist[, kansio := strsplit(polku, split = "/")[[1]][1], by = rivi])
  sourcelist <- sourcelist[!grep("load_scripts.R", polku)]
  sourcelist[, kansio := ifelse(str_sub(kansio, -2, -1) == ".R", "root", kansio)]


  input_kansio_list <- c(
    "tab"
  )
  for(input_kansio in input_kansio_list) {
    dir_list <- sourcelist[kansio == input_kansio, polku]
    for(filename in dir_list) {
      result = tryCatch({
        print(paste0("sourced ", filename))
        source(paste0("./scripts/", filename), local = TRUE)
      }, error = function(e) {
        print(paste0("error in loading file: ", filename))
      })
    }
  }


})
