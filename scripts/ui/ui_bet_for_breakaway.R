choise_ids <- c(1, 2)
names(choise_ids) <- c("Rouler", "Sprinteur")

tabItem(tabName = "tab_bet_for_breakaway",
        fluidPage(fluidRow(radioGroupButtons(inputId = "which_cycler_to_bet",
                                    "Choose cycler to participate in betting",
                                    choices = choise_ids),
                  actionButton(inputId = "confirm_better", label = "Confirm betting cycler"))),
        fluidRow(
        tableOutput(outputId = "breakaway_results")),
        fluidRow(        uiOutput(outputId = "breakaway_options")),
        fluidRow(  actionButton(inputId = "save_betted_card", label = "Confirm selected card")),
        fluidRow(uiOutput("betting_done"))

)
