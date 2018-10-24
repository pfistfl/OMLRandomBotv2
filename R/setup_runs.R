library(batchtools)
source("tasks.R")
source("learners.R")
source("helpers.R")
source("Bot.R")

# FIXME: Learner Packages
# FIXME: Source files
reg = load_or_create_registry("randombot_reg", overwrite = FALSE)

#' Function that runs the Bot
runBot = function(task.id) {
  bot = RandomBot$new(as.character(task.id))
  bot$run()
  # FIXME: How do we save to disk? Just the return value?
  # FIXME: Check size of the OML Run
}

for (task.id in task.ids) {
  addProblem(name = task.id, data = list(task.id = task.id), seed = 42)
}

addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
  result = runBot(data$task.id)
  return(result)
})

addExperiments(repls = REPLS)
