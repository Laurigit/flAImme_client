
luettu <- dbSelectAll("ADM_OPTIMAL_MOVES", con)

ADM_OPTIMAL_MOVES <- fix_colnames(luettu)

#available tournaments
tournament <- reactiveValues(data = dbSelectAll("TOURNAMENT", con))

move_to <- reactiveValues(tab = "")

update_breakaway_bet <- reactiveValues(data = 0)

shinyServer(function(input, output, session) {

  player_reactive <- reactiveValues(name = NULL,
                                    team = NULL,
                                    tournament = NULL)


  reactive({

    updateTabItems(session, "sidebarmenu", selected = move_to$tab)

  })


  #try to read status of breakaway bets
 #breakaway_bets_data <-  my_reactivePoll(session, "BREAKAWAY_BET", paste0('SELECT count(TEAM_ID) from BREAKAWAY_BET'), timeout = 1000, con)
 breakaway_cards <-  my_reactivePoll(session, "BREAKAWAY_BET_CARDS", paste0('SELECT * from BREAKAWAY_BET_CARDS'), timeout = 1000, con)





  react_status <- reactiveValues(phase = 0,
                                 cycler_in_turn = 0,
                                 action_data = NULL,
                                 turn = 0,
                                 last_played_card = 0,
                                 first_cycler = 0,
                                 game_status = 0,
                                 deck_status = 0,
                                 precalc_track_agg = 0,
                                 ctM_data = 0,
                                 AI_team = 0,
                                 range_joined_team = 0,
                                 game_phase = 0)

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
