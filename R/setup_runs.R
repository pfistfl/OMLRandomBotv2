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
  # FIXME: How do we save to disk?
}

for (task.id in task.ids) {
  addProblem(name = as.character(task.id), data = list(task.id = as.character(task.id)), seed = 42)
}

addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
  result = runBot(data$task.id)
  return(result)
})

addExperiments(repls = REPLS)
