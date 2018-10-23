library(R6)
library(OpenML)

Bot = R6Class("OMLBot",

  public = list(
    task.id = NULL,

    initialize = function(task.id) {
      self$task.id = task.id

    },

    run = function() {
      lrn = sample_learner_config()
      oml.task = getOMLTask(self$task.id)
      tsk = convertOMLTaskToMlr()
      run = runTaskMlr(lrn, tsk$mlr.task, tsk$mlr.rin, tsk$mlr)
      return(run)
    }
  ),

  private = list()
)


RandomBot = R6Class("RandomOMLBot",
  inherit = Bot,

  public = list(
    initialize = function(task.id) {
    },

    run = function() {

    }
  )

  private = list(
    #' Obtain random learner and hyperpars, return configured learner
    #' @return learner with matching parameter set
    #' @export
    sample_learner_config = function() {
      private$learner = sample_random_learner()
      private$par.set = sample_random_config()
      lrn = setHyperPars(private$learner, par.vals = private$par.set)
      return(lrn)
    }
    #' Sample a random learner with matching parameter set from the lrn.ps.sets list
    #' @param lrn.ps.sets of available learners with matching parameter sets
    #' @return list of one learner with matching parameter set
    #' @export
    sample_random_learner = function() {
      sample(self$learners, size = 1)[[1]]
    },
    #' Sample a random configuration for a selected learner
    #' @param size number of configurations to generate
    #' @return data.frame where each row is one valid configuration
    #'
    #' @export
    sample_random_config = function(size = 1L) {
      des = generateRandomDesign(size, self$par.set, trafo = TRUE)
      des = BBmisc::convertDataFrameCols(des, factors.as.char = TRUE)
      return(des)
    }
  )
)
