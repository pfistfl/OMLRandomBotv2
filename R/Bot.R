library(R6)
library(OpenML)
library(BBmisc)

#-----------------------------------------------------------------------------------------
#' Class OMLBot
#' Public Members:
#' task.id [character(1)]
#' task [Task]
#'
#' initialize [function(task.id)]
#' run [function()]
#'
#' Private Members:
#' learner [learner]
#' parset [ParamSet]
#' pars [list]
#'
#' get_learner_config [function()]
#'
Bot = R6Class("OMLBot",

  public = list(
    task.id = NULL,
    oml.task = NULL,
    task = NULL,

    initialize = function(task.id) {
      self$task.id = task.id
    },

    run = function() {
      self$oml.task = getOMLTask(as.numeric(self$task.id))
      self$task = convertOMLTaskToMlr(oml.task)$mlr.task
      lrn = private$get_learner_config()
      measures = private$get_measures()
      run = runTaskMlr(oml.task, lrn, measures)
      return(run)
    }
  ),

  private = list(
    learner = NULL,
    parset = NULL,
    pars = NULL,
    get_learner_config = function() {}
    )
)

#-----------------------------------------------------------------------------------------
#' Class RandomOMLBot
#' inherits from [OMLBot]
#' Public Members:
#' < inherited >
#'
#' Private Members:
#'
#' get_learner_config [function()]
#' sample_random_learner [function()]
#' get_learner_parset [function()]
#' sample_random_config [function()]
#'
RandomBot = R6Class("RandomOMLBot",
  inherit = Bot,

  public = list(),

  private = list(
    #' Sample random learner and hyperpars, return configured learner
    #' @return learner with matching parameter set
    get_learner_config = function() {
      private$learner = private$sample_random_learner()
      private$parset = private$get_learner_parset()
      private$pars = private$sample_random_config()
      lrn = setHyperPars(private$learner, par.vals = private$pars)
      # FIXME: How do we send additional, learner dependent configs
      #        like nthread for xgboost
      return(lrn)
    },
    #' Sample a random learner from a set of learners
    #' @return list of one learner with matching parameter set
    sample_random_learner = function() {
      lrn = list_learners(self$task)
        # Sample according to learner parameter set dimensions
      lrn.probs = get_learner_probs(lrn)
      lrn.cl = sample(lrn, size = 1, prob = lrn.probs)
      lrn = makeLearner(lrn.cl)
      # Set predict.type
      if ("prob" %in% getLearnerProperties(lrn))
        lrn = setPredictType(lrn, "prob")
      return(lrn)
    },
    #' Get a learner parset for a sampled learner
    #' @return A ParamSet
    get_learner_parset = function() {
      get_parset(private$learner, self$task)
    },
    #' Sample a random configuration for a selected learner
    #' @return data.frame where each row is one valid configuration
    sample_random_config = function() {
      des = generateRandomDesign(1, private$parset, trafo = TRUE)
      des = BBmisc::convertDataFrameCols(des, factors.as.char = TRUE)
      des = as.list(des)
      des = Filter(function(x) {!is.na(x)}, des)
      return(des)
    },
    get_measures = function() {
      measures = list(acc, bac, auc, f1, brier, timetrain, timepredict, timeboth)
      # No measures that require probs if learner can not do probabilities
      if (getLearnerPredictType(private$learner) != "prob") {
        probs.measures = listMeasures(self$task, properties = prop, create = TRUE)
        measures = setdiff(measures, probs.measures)
      }
      # No measures that require binary class if learner can not do probabilities
      measures = intersect(measures, listMeasures(self$task, create = TRUE))
      return(measures)
    }
  )
)
