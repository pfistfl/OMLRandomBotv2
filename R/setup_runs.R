library(batchtools)

source.pkgs = c("mlr", "R6", "OpenML", "data.table", "ParamHelpers")
source.files = paste0("R/", c("Bot.R", "tasks.R", "learners.R", "helpers.R"))
sapply(source.files, source)

reg = load_or_create_registry("randombot_reg", overwrite = TRUE,
  source.files = source.files, source.pkgs = source.pkgs)

for (task.id in task.ids) {
  addProblem(name = get_task_name(task.id), data = list(task.id = task.id), seed = 42)
}

addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
  bot = RandomBot$new(data$task.id)
  bot$run()
  # FIXME: How do we save to disk?
  #        I guess via batchtools result
})

addExperiments(repls = 1)

