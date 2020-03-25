#library(shiny)
#library(shinydashboard)

# Define UI for application that draws a histogram


uusi_peli <- dashboardBody(

  useShinyjs(),
  tags$script("$(\"input:radio[name='blue_setup'][value='Human']\").parent().css('background-color', '#DE6B63');"),

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

              menuItem("Add custom track", icon = icon("trophy"), tabName = "tab_add_track"),
              menuItem("Start positions",icon = icon("bar-chart"), tabName = "tab_start_positions"),
              menuItem("Bet for breakaway", icon = icon("bar-chart"), tabName = "tab_bet_for_breakaway"),
              menuItem("Play cards", icon = icon("bar-chart"), tabName = "tab_human_input"),
              menuItem("Game status", icon = icon("bar-chart"), tabName = "tab_game_status")


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

               dashboardHeader(title = textOutput('Username')),

               sidebar,
               uusi_peli
)




