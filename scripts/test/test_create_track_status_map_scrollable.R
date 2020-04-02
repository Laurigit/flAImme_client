test_track <- create_track_table(30, STG_TRACK_PIECE, STG_TRACK)



test_track_cut <- test_track[is.na(EXTRA)]
test_track_cut[1:12, CYCLER_ID := 1:12]



track_info <- create_track_ui_info(STG_TRACK, STG_TRACK_PIECE, 30)

create_track_status_map_scrollable(ADM_CYCLER_INFO,test_track_cut, track_info, 1)
