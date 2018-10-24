library(batchtools)

source.pkgs = list("mlr", "R6", "OpenML", "data.table")
source.files = c("Bot.R", "tasks.R", "learners.R", "helpers.R", "Bot.R")
sapply(source, source.files)

reg = load_or_create_registry("randombot_reg", overwrite = FALSE,
  source.files = source.files, source.pkgs = source.pkgs)


for (task.id in task.ids) {
  addProblem(name = task.id, data = list(task.id = as.character(task.id)), seed = 42)
}

addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
  bot = RandomBot$new(as.character(data$task.id))
  # FIXME: How do we save to disk?
  # 	   I guess via batchtools result.
  result = bot$run()
  return(result)
})

addExperiments(repls = REPLS)
