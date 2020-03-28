observeEvent(input$save_custom_track, {

sql_ins <- paste0('INSERT INTO TRACK (TRACK_NAME, TRACK_PIECE_VECTOR) VALUES (\'',
                  input$new_track_name, '\', \'',
                  input$track_letters,
                  '\')')
dbQ(sql_ins, con)
updateTextInput(session,
                inputId = "new_track_name",
                value = "")
updateTextInput(session,
                inputId = "track_letters",
                value = "")
updateTabItems(session, "sidebarmenu", selected = "tab_game_setup")
})


eR_TRACK <- eventReactive(input$save_custom_track, {
  required_data("SRC_TRACK", force_update = TRUE)
  required_data("STG_TRACK", force_update = TRUE)
  STG_TRACK
}, ignoreNULL = FALSE)


observeEvent(input$save_custom_track, {
  #tell server to update tracks
  con <- connDB(con, "flaimme")
  command <- data.table(TOURNAMENT_NM = input$join_tournament, COMMAND = "UPDATE_TRACKS")
  dbIns("CLIENT_COMMANDS", command, con)

})
