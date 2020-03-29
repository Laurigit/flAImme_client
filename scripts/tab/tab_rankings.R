#tab_rankings

output$select_race <- renderUI({
  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  stats <- create_finish_stats(tn_data)

  races <- stats[, .N, by = GAME_ID][, GAME_ID]
  selected_race <- stats[, max(GAME_ID)]

selectInput(inputId = "select_race", label = "Race number", choices = races, selected = selected_race)

})


output$show_race_stats <- DT::renderDataTable({
  req(input$select_race)
  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  stats <- create_finish_stats(tn_data)
  stats[, nice_time := paste0("+", seconds_to_period(TIME))]
  sel_race <- stats[GAME_ID == input$select_race, .(CYCLER_ID, POINTS, TIME = nice_time)]
  cyc_info <- ADM_CYCLER_INFO[,. (CYCLER_ID, TEAM_ID, CYCLER_TYPE_NAME)]

  join_info <- cyc_info[sel_race, on = "CYCLER_ID"]

  player_names <- tournament$data[TOURNAMENT_NM == input$join_tournament, .(TEAM_ID, PLAYER_NM)]
  join_names <- player_names[join_info, on = "TEAM_ID"]
  rs <- datatable(join_names[, .(Player = PLAYER_NM,
                                 Cycler = CYCLER_TYPE_NAME,
                                 Points = POINTS,
                                 Time = TIME)], rownames = FALSE, options = list(info = FALSE,
                                                                                autoWidth = TRUE,
                                                                                columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                paging = FALSE, dom = 't',ordering = F))
  rs
})



output$show_tour_cylers <- DT::renderDataTable({

  req( input$join_tournament)
  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  stats <- create_finish_stats(tn_data)
  #aggr_stats
  attr_stats_cycler <- stats[, .(POINTS = sum(POINTS),
                          TIME = sum(TIME)),
                          by = CYCLER_ID
                          ]
  attr_stats_cycler
  attr_stats_cycler[, nice_time := paste0("+", seconds_to_period(TIME))]

  cyc_info <- ADM_CYCLER_INFO[,. (CYCLER_ID, TEAM_ID, CYCLER_TYPE_NAME)]

  join_info <- cyc_info[attr_stats_cycler, on = "CYCLER_ID"]


  player_names <- tournament$data[TOURNAMENT_NM == input$join_tournament, .(TEAM_ID, PLAYER_NM)]
  join_names <- player_names[join_info, on = "TEAM_ID"]
  rs <- datatable(join_names[, .(Player = PLAYER_NM,
                                 Cycler = CYCLER_TYPE_NAME,
                                 Points = POINTS,
                                 Time = nice_time)], rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE, dom = 't',ordering = F))
  rs
})

output$show_tour_teamsc <- DT::renderDataTable({

  req(input$join_tournament)
  tn_data <- tournament_result$data[TOURNAMENT_NM == input$join_tournament]
  stats <- create_finish_stats(tn_data)
  cyc_info <- ADM_CYCLER_INFO[,. (CYCLER_ID, TEAM_ID, CYCLER_TYPE_NAME)]

  join_info <- cyc_info[stats, on = "CYCLER_ID"]
  #aggr_stats
  attr_stats_cycler <- join_info[, .(POINTS = sum(POINTS)),
                             by = TEAM_ID ]



  player_names <- tournament$data[TOURNAMENT_NM == input$join_tournament, .(TEAM_ID, PLAYER_NM)]
  join_names <- player_names[attr_stats_cycler, on = "TEAM_ID"]
  rs <- datatable(join_names[, .(Player = PLAYER_NM,
                                 Points = POINTS)], rownames = FALSE, options = list(info = FALSE,
                                                                                      autoWidth = TRUE,
                                                                                      columnDefs = list(list(width = '10px', targets = "_all")),
                                                                                      paging = FALSE, dom = 't',ordering = F))
  rs
})
