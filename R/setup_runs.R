library(batchtools)
source.pkgs = list("mlr", "R6", "OpenML", "data.table")
source.files = c("Bot.R", "tasks.R", "learners.R", "helpers.R", "Bot.R")
sapply(source, source.files)
reg = load_or_create_registry("randombot_reg", overwrite = FALSE,
  source.files = source.files, source.pkgs = source.pkgs)

#' Function that runs the Bot
runBot = function(task.id) {
  bot = RandomBot$new(as.character(task.id))
  bot$run()
  # FIXME: How do we save to disk?
  # 	   I guess via batchtools result
}

for (task.id in task.ids) {
  addProblem(name = task.id, data = list(task.id = as.character(task.id)), seed = 42)
}

addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
  result = runBot(data$task.id)
  return(result)
})

addExperiments(repls = REPLS)
