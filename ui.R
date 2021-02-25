#library(shiny)
#library(shinydashboard)

# Define UI for application that draws a histogram


uusi_peli <- dashboardBody(

  useShinyjs(),
 # tags$style(type = "text/css", "#game_map_full {height: calc(98vh - 130px) !important;}"),
 tags$style(type = "text/css", "#game_map_full {height: calc(98vh - 100px) !important;}"),
  tags$style(type = "text/css", "#game_map_scroll {height:4500px !important;}"),
  tags$script("$(\"input:radio[name='blue_setup'][value='Human']\").parent().css('background-color', '#DE6B63');"),
 extendShinyjs(text = "shinyjs.hidehead = function(parm){
                                    $('header').css('display', parm);
                                }", functions = c("hidehead")),
 tags$script(
   '
    Shiny.addCustomMessageHandler("scrollCallback",
    function(msg) {
    console.log("aCMH" + msg)
    var objDiv = document.getElementById("game_map_scroll");
    objDiv.scrollTop = objDiv.scrollHeight - objDiv.clientHeight;
    console.dir(objDiv)
    console.log("sT:"+objDiv.scrollTop+" = sH:"+objDiv.scrollHeight+" cH:"+objDiv.clientHeight)
    }
    );'
 ),

  tags$head(
    tags$style(
      HTML("
           #myScrollBox{
           overflow-y: scroll;
           overflow-x: hidden;
           height:740px;
           }
           ")
      )
    ,

    tags$style(type = "text/css", "
               .irs-slider {width: 30px; height: 30px; top: 22px;}
               ")


    ),
  tabItems(
    #  source("./scripts/ui/ui_uusi_peli.R",local = TRUE)$value,
    #  source("./scripts/ui/ui_tallenna_peli.R",local = TRUE)$value,
    source("./scripts/ui/ui_join_game.R",local = TRUE)$value,
    source("./scripts/ui/ui_game_setup.R",local = TRUE)$value,
    source("./scripts/ui/ui_add_track.R",local = TRUE)$value,
    source("./scripts/ui/ui_start_positions.R",local = TRUE)$value,
    source("./scripts/ui/ui_human_input.R",local = TRUE)$value,
   # source("./scripts/ui/ui_deal_cards.R",local = TRUE)$value,
    source("./scripts/ui/ui_play_card.R",local = TRUE)$value,
    source("./scripts/ui/ui_bet_for_breakaway.R",local = TRUE)$value,
    source("./scripts/ui/ui_game_status.R",local = TRUE)$value,
   source("./scripts/ui/ui_rankings.R",local = TRUE)$value,
    source("./scripts/ui/ui_input_other_moves.R",local = TRUE)$value
 #   source("./scripts/ui/ui_manage_deck.R",local = TRUE)$value
    # source("./scripts/ui/ui_pakkaupload.R",local = TRUE)$value,
    # source("./scripts/ui/ui_saavutusasetukset.R",local = TRUE)$value,
    # source("./scripts/ui/ui_boosterit.R",local = TRUE)$value,
    # source("./scripts/ui/ui_decks.R",local = TRUE)$value,
    # source("./scripts/ui/ui_deck_lists.R",local = TRUE)$value
    #  source("./scripts/ui/ui_life_counter.R",local = TRUE)$value,

  ))

#SIDEBAR
sidebar <- dashboardSidebar(
  sidebarMenu(id = "sidebarmenu",
              menuItem("Join game", icon = icon("beer"), tabName = "tab_join_game"),

              menuItem("Game setup", icon = icon("beer"), tabName = "tab_game_setup"),

              menuItem("Add custom track", icon = icon("bar-chart"), tabName = "tab_add_track"),
              menuItem("Start positions",icon = icon("bar-chart"), tabName = "tab_start_positions"),
              menuItem("Bet for breakaway", icon = icon("bar-chart"), tabName = "tab_bet_for_breakaway"),
              menuItem("Stats", icon = icon("bullseye"), tabName = "tab_human_input"),
              menuItem("Play", icon = icon("sliders-h"), tabName = "tab_game_status"),
              menuItem("Rankings", icon = icon("trophy"), tabName = "tab_rankings")



           #   menuItem('Manage deck',  icon = icon("sliders-h"),tabName = 'tab_manage_deck'),
            #  menuItem("Deal cards",icon = icon("bullseye"),tabName = "tab_deal_cards"),
           #   menuItem('Play card', icon = icon("tasks") ,tabName = 'tab_play_card'),
           #   menuItem('Input human moves',  icon = icon("sliders-h"),tabName = 'tab_input_other_moves')

  )


)

#RUNKO
dashboardPage( title = "flAImme Rouge",

               #dashboardHeader(title = paste0("run_mode = ", GLOBAL_test_mode, " ", textOutput('blow_timer')),
               #  dashboardHeader(title = textOutput('blow_timer'),
               #                 titleWidth = 450),

               dashboardHeader(title = "game setup"),

               sidebar,
               uusi_peli
)





