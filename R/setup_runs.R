library(batchtools)


# FIXME: Learner Packages
# FIXME: Source files
source.pkgs = list("mlr", "R6", "OpenML", "data.table")
source.files = c("Bot.R", "tasks.R", "learners.R", "helpers.R", "Bot.R")
sapply(source, source.files)

reg = load_or_create_registry("randombot_reg", overwrite = FALSE,
  source.files = source.files, source.pkgs = source.pkgs)


for (task.id in task.ids) {
  addProblem(name = task.id, data = list(task.id = task.id), seed = 42)
}


addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
  bot = RandomBot$new(data$task.id)
  bot$run()
  # FIXME: How do we save to disk?
  #        I guess via batchtools result
})

addExperiments(repls = REPLS)
