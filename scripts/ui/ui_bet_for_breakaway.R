choise_ids <- c(1, 2)
names(choise_ids) <- c("Rouler", "Sprinteur")

tabItem(tabName = "tab_bet_for_breakaway",
        fluidPage(radioGroupButtons(inputId = "which_cycler_to_bet",
                                    "Choose cycler to participate in betting",
                                    choices = choise_ids),
                  actionButton(inputId = "confirm_better", label = "Confirm betting cycler")),
        tableOutput(outputId = "breakaway_results"),
        uiOutput(outputId = "breakaway_options"),
        actionButton(inputId = "save_betted_card", label = "Confirm selected card")
)
