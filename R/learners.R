# Definition of all learners and corresponding param sets

#' List available learners for a given task
#' task [Task] input task
list_learners = function(task) {
  # Only list learners that work with the task the 
  bot.lrns = c("classif.glmnet", "classif.rpart", "classif.knn",
  	"classif.svm", "classif.ranger", "classif.xgboost")
  bot.pardim = c(2, 4, 2, 4, 6, 8)
  
  avail.lrns = listLearners(task, quiet = TRUE,
   warn.missing.packages = FALSE)$class
  lrn.inds = which(bot.lrns %in% availlrns)

  # Sample according to learner parameter set dimensions
  lrns = bot_lrns[lrn.inds]
  learner.probs = bot_pardim[lrninds] / sum(bot_pardim[lrn.inds])
  return(list(learners = lrns, learner.probs = learner.probs))
}

#' Create the paramset for a given learner or task
#' task [Task] input task
#' learner [Learner] learner
make_parset = function(learner, task) {
  # FIXME
  return(ps)
}
