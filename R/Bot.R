library(R6)
library(OpenML)

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
    task = NULL,

    initialize = function(task.id) {
      self$task.id = as.character(task.id)
    },

    run = function() {
      oml.task = getOMLTask(self$task.id)
      self$task = convertOMLTaskToMlr()
      lrn = get_learner_config()
      run = runTaskMlr(lrn, self$task$mlr.task, self$task$mlr.rin, self$task$mlr)
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
      lrn = setHyperPars(private$learner, par.vals = private$parset)
      return(lrn)
    },
    #' Sample a random learner from a set of learners
    #' @return list of one learner with matching parameter set
    sample_random_learner = function() {
      lrn = list_learners(self$task)
      lrn.cl = sample(lrn$learners, size = 1, prob = lrn$learner.probs)[[1]]
      # FIXME: Set probs, other pars here?
      makeLearner(lrn.cl)
    },
    #' Get a learner parset for a sampled learner
    #' @return A ParamSet
    get_learner_parset = function() {
      make_parset(private$learner, private$task)
    },
    #' Sample a random configuration for a selected learner
    #' @return data.frame where each row is one valid configuration
    sample_random_config = function() {
      des = generateRandomDesign(1, private$parset, trafo = TRUE)
      des = BBmisc::convertDataFrameCols(des, factors.as.char = TRUE)
      return(des)
    }
  )
)
