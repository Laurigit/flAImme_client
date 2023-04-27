test_track <- create_track_table(1, STG_TRACK_PIECE, STG_TRACK)



test_track_cut <- test_track[is.na(EXTRA)]
test_track_cut[1:12, CYCLER_ID := 1:12]



track_info <- create_track_ui_info(STG_TRACK, STG_TRACK_PIECE, 1)

create_track_status_map_scrollable(ADM_CYCLER_INFO,test_track_cut, track_info, 1, c(1,3))

create_track_status_map_scrollable(ADM_CYCLER_INFO,test_track_cut, track_info, 1, c(1,3))
