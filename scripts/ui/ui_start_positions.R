tabItem(tabName = "tab_start_positions",
fluidPage(
  fluidRow(
           column(4, uiOutput("select_track")),
           column(4, actionButton("go_to_add_track_tab",
                                  label = "Add custom track"))),
  fluidRow(
        column(width = 3, h2("Peloton"), uiOutput("cyclersInput", style = "min-height:200px;background-color:white;")),
        column(width = 3, h2("Breakaway"), uiOutput("cyclersPeloton", style = "min-height:200px;background-color:white;")),
        column(width = 3, h2("Move ready here"), uiOutput("ready", style = "min-height:200px;background-color:white;")),
       # actionButton("save_initial_grid", "Save grid order", width = "33%"),
        actionButton("bet_for_breakaway", "Bet for breakaway", width = "33%"),
        actionButton("start_game", "Start game", width = "33%")

)),
dragula(c("cyclersInput","cyclersPeloton", "ready"), id = "dragula")
)
