library(batchtools)
source("tasks.R")
source("learners.R")
source("helpers.R")
source("Bot.R")

reg = load_or_create_registry("randombot_reg", overwrite = FALSE)

#' Function that runs the Bot
runBot = function(task.id) {
  bot = RandomBot$new(as.character(task.id))
  bot$run()
}

for (task in task.ids) {
  addProblem(name = task, fun = runBot, seed = 42)
}
