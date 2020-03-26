# library(reshape2); library(ggplot2)
#
# colors <- c("green", "yellow", "red", "black", "blue")
# dfA <- data.frame(c(2,3,1,2,3,1,2,3,1,2,3,1,2,3),
#                   c(1,1,2,2,2,3,3,3,4,4,4,5,5,5),
#                   c(0,1,0,0,2,0,0,0,2,0,0,4,0,0),
#                   c( "R", "", "", "S", "S", "", "R", "R", "", "", "S", "S", "", ""))
#
# #CYCLER_TYPE, PIECE_ATTRIBUTE, X = LANE, Y = GAME_SLOT_ID, Z = TEAM_COLOR
#
# names(dfA) = c("x", "y", "z", "text")
# p1 <- ggplot(dfA,
#        aes(x = x, y = y, fill = factor(z))) +
#    #geom_tile(color = "gray", size = 5) +
#   geom_tile(aes(fill = factor(z), color=as.factor(z), width=0.9, height=0.9), size=2) +
#   geom_text(aes(label = text, color = as.factor(z + 1)), size = 10) +
#   scale_fill_manual(values=colors) +
#   scale_colour_manual(values=c("6" = "yellow", "5" = "red", "4" = "black", "2" = "blue", "3" = "green","1" =  "white"))
#
#
# p1
# p2 <- p1
# p2
#
# grid.arrange(p1, p2, nrow = 1, ncol = 2)
# ?grid.arrange
#
# +
#   scale_colour_manual(values=c("yellow", "red", "black", "blue", "green", "white"))
#
#   #+
# #  ylim( limits = c(1,5) )
# p1
#
#
# p1 <- ggplot(dfA,
#              aes(x = x, y = y, fill = factor(2))) +
#   #geom_tile(color = "gray", size = 5) +
#   geom_tile(aes(color=as.factor(1), width=0.9, height=0.9), size=2) +
#   geom_text(aes(label = text, color = as.factor(z + 1)), size = 10) +
#   scale_fill_manual(values=c("6" = "yellow", "5" = "red", "4" = "black", "2" = "blue", "3" = "green","1" =  "white")) +
#   scale_colour_manual(values=c("6" = "yellow", "5" = "red", "4" = "black", "2" = "blue", "3" = "green","1" =  "white"))
# p1 +     scale_y_discrete(
#   limits=c("1","2","3","4","5","6", "7", "8", "9"), breaks=seq(01,9,1), label = 1:9)
#
#
#
