#' List available learners for a given task
#' @param task [Task] input task
#' @return [character(n)] vector of learner.ids
list_learners = function(task) {
  # Only list learners that work with the task:
  bot.lrns = c("classif.glmnet", "classif.rpart", "classif.kknn",
  	"classif.svm", "classif.ranger", "classif.xgboost")
  # FIXME: Is this to strict?
  # We might want to allow for wrappers
  avail.lrns = mlr::listLearners(task, properties = c("multiclass", "missings", "probs"),
   quiet = TRUE, warn.missing.packages = FALSE)$class
  lrn.inds = which(bot.lrns %in% avail.lrns)
  return(learners = bot.lrns[lrn.inds])
}


#' Get probabilities to draw a learner
#' @param learners [character(n)] vector of learner id's
#' @param sampling [character(1)] "uniform" or "parset_dims".
#'   "uniform" draws each learner equally likely, while parset dims
#'   draws learners proportional to their parameter set dimensions.
#' @return [numeric(n)] sampling probabilities for each learner
get_learner_probs = function(learners, sampling = "parset_dims") {
  if (sampling == "uniform") {
    wts = rep(1, seq_along(learners))
  } else if (sampling == "parset_dims") {
    wts = sapply(learners, function(x) {
      parset = get_parset(x, add_fixed_pars = FALSE)
      getParamNr(parset)
    })
  }
  return(wts / sum(wts))
}


#' Create the paramset for a given learner or task
#' @param oml.task [OMLTask] input task (for data dependent parameters)
#' @param learner [Learner] learner
#' @param extra.pars [logical(1)] should extra non-hyperparameters (e.g. nthread) be added?
#' @return [ParamSet]
get_parset = function(learner, oml.task = NULL, add_fixed_pars = TRUE) {
  learner = checkLearner(learner)
  switch(learner$id,
    "classif.glmnet" = make_check_parset(learner, add_fixed_pars,
      parset = makeParamSet(
        makeNumericParam("alpha", lower = 0, upper = 1, default = 1),
        makeNumericVectorParam("lambda", len = 1L, lower = -10, upper = 10, default = 0,
          trafo = function(x) 2^x))
      ),
    "classif.rpart" = make_check_parset(learner, add_fixed_pars,
      parset = makeParamSet(
        makeNumericParam("cp", lower = 0, upper = 1, default = 0.01),
        makeIntegerParam("maxdepth", lower = 1, upper = 30, default = 30),
        makeIntegerParam("minbucket", lower = 1, upper = 60, default = 1),
        makeIntegerParam("minsplit", lower = 1, upper = 60, default = 20))
      ),
    "classif.kknn" = make_check_parset(learner, add_fixed_pars,
      parset = makeParamSet(makeIntegerParam("k", lower = 1, upper = 30))
        ),
    "classif.svm" = make_check_parset(learner, add_fixed_pars,
      parset = makeParamSet(
        makeDiscreteParam("kernel", values = c("linear", "polynomial", "radial")),
        makeNumericParam("cost", lower = -10, upper = 10, trafo = function(x) 2^x),
        makeNumericParam("gamma", lower = -10, upper = 10, trafo = function(x) 2^x, requires = quote(kernel == "radial")),
        makeIntegerParam("degree", lower = 2, upper = 5, requires = quote(kernel == "polynomial")))
        ),
    "classif.ranger" = {
      task.metadata = get_task_metadata(oml.task)
      make_check_parset(learner, add_fixed_pars,
      parset = makeParamSet(
        makeIntegerParam("num.trees", lower = 1, upper = 2000),
        makeLogicalParam("replace"),
        makeNumericParam("sample.fraction", lower = 0.1, upper = 1),
        makeIntegerParam("mtry", lower = 0, upper = task.metadata$p),
        makeDiscreteParam("respect.unordered.factors", values = c("ignore", "order", "partition")),
        #FIXME: Compare to trafo from old random bot
        # makeIntegerParam("min.node.size", lower = 0, upper = 1, trafo = function(x) task.metadata$n^x),
        makeIntegerParam("min.node.size", lower = 1, upper = min(60, task.metadata$n)),
        makeDiscreteParam("splitrule", values = c("gini", "extratrees")))
        )
      },
    "classif.xgboost" = make_check_parset(learner, add_fixed_pars,
      # FIXME: Sample gbtree and gblinear with equal probabilities?
      parset = makeParamSet(
        makeIntegerParam("nrounds", lower = 1, upper = 5000),
        makeNumericParam("eta", lower = -10, upper = 0, trafo = function(x) 2^x),
        makeNumericParam("subsample",lower = 0.1, upper = 1),
        makeDiscreteParam("booster", values = c("gbtree", "gblinear")),
        makeIntegerParam("max_depth", lower = 1, upper = 15, requires = quote(booster == "gbtree")),
        makeNumericParam("min_child_weight", lower = 0, upper = 7, requires = quote(booster == "gbtree"), trafo = function(x) 2^x),
        makeNumericParam("colsample_bytree", lower = 0, upper = 1, requires = quote(booster == "gbtree")),
        makeNumericParam("colsample_bylevel", lower = 0, upper = 1, requires = quote(booster == "gbtree")),
        makeNumericParam("lambda", lower = -10, upper = 10, trafo = function(x) 2^x),
        makeNumericParam("alpha", lower = -10, upper = 10, trafo = function(x) 2^x)),
      fixed_pars = makeParamSet(makeIntegerParam("nthread", lower = 1, upper = 1))
      )
    )
}


#' Create and check a Paramset
#' @description  Create a learner-parameter set.
#'   Check whether param set and learner amtch
#' @param learner [Learner] object
#' @param parset [ParamSet], that matches the learner
#' @return [ParamSet]
make_check_parset = function(learner, add_fixed_pars, parset, fixed_pars = NULL) {
  # FIXME: The add_fixed_pars is currently a little ugly.
  #        We can improve this at some point
  checkLearner(learner)
  checkParamSet(parset)
  if (!is.null(fixed_pars) & add_fixed_pars)
    checkParamSet(fixed_pars)

  par.match = names(parset$pars) %in% names(learner$par.set$pars)
  if(!all(par.match)){
    stop(paste("The following parameters in param.set are not included in learner:",
      paste(names(parset$pars[par.match == FALSE]), collapse = ", ")))
  }
  if (add_fixed_pars) parset = c(parset, fixed_pars)
  return(parset)
}
