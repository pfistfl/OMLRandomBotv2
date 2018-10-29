test_that("RandomBot", {
  library(OpenML)
  cc18 = listOMLTasks(tag = "OpenML-CC18")
  task.ids = c(11, 12)

  #' Get a task name from a task.id
  get_task_name = function(task.id) {
    cc18[cc18$task.id == task.id, "name"]
  }

  library(batchtools)
  # FIXME: Make this better
  regpath = "tests/test_registry"

  source.pkgs = c("mlr", "R6", "OpenML", "data.table", "ParamHelpers")
  source.files = paste0("R/", c("Bot.R", "tasks.R", "learners.R", "helpers.R"))
  sapply(source.files, source)


  reg = load_or_create_registry(regpath, overwrite = TRUE,
    source.files = source.files, source.pkgs = source.pkgs)

  for (task.id in task.ids) {
    addProblem(name = get_task_name(task.id), data = list(task.id = task.id), seed = 42)
  }
  addAlgorithm("randomBot", fun = function(job, data, instance, ...) {
    bot = RandomBot$new(data$task.id)
    bot$run()
  })
  addExperiments(repls = 2)

  submitJobs(findNotDone())
  status = getStatus()
  # Delete registry after tests
  unlink(regpath, force = TRUE)
})
