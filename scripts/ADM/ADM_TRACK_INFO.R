create_track_ui_info <- function(STG_TRACK, STG_TRACK_PIECE, input_track) {


#input_track <- 1
currtrack <- STG_TRACK[input_track == TRACK_ID, TRACK_PIECE_VECTOR]
splitted_track <- data.table(TRACK_PIECE_ID = strsplit(currtrack, split = "")[[1]])
splitted_track[, order := seq_len(.N)]

sscols <- STG_TRACK_PIECE[, .(TRACK_PIECE_ID, LANES, PIECE_ATTRIBUTE, PIECE_SLOT, START, FINISH, ALIGN, TRACK_PIECE_ID_GAME, TRACK_PIECE_COLOR_GAME)]

#Game_slot_id	Lane_1	Lane_2	Lane_3	Attribue	Finish

joinaa_normi <- sscols[splitted_track, on = "TRACK_PIECE_ID"]
joinaa_normi[, ':=' (GAME_SLOT_ID = seq_len(.N),
               order = NULL)]

row_rep <- joinaa_normi[rep(1:.N,LANES)][,LANE_NO:=1:.N,by=GAME_SLOT_ID]
# kaadettu <- dcast.data.table(row_rep, TRACK_PIECE_ID + PIECE_ATTRIBUTE + START + FINISH + GAME_SLOT_ID ~ Indx, value.var = "dcast_value")
#colnames(kaadettu)[(length(kaadettu) - max_lanes + 1):length(kaadettu)] <- laneCols
sort <- row_rep[order(GAME_SLOT_ID, -LANE_NO)]
sort[, ':=' (
             LANES = NULL,
             SQUARE_ID = seq_len(.N)
             )]
sort[, COORD := ifelse(LANE_NO == 1, paste0(TRACK_PIECE_ID_GAME, "-" ,PIECE_SLOT),
                       paste0(TRACK_PIECE_ID_GAME, "-" ,PIECE_SLOT, ":", LANE_NO))]

return(sort)
}
