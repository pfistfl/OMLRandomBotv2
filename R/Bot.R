library(R6)
library(OpenML)

Bot = R6Class("OMLBot",

  public = list(
    task.id = NULL,
    task = NULL,

    initialize = function(task.id) {
      self$task.id = task.id
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
    get_learner_config = function() {}
    )
)


RandomBot = R6Class("RandomOMLBot",
  inherit = Bot,

  public = list(),

  private = list(
    #' Sample random learner and hyperpars, return configured learner
    #' @return learner with matching parameter set
    #' @export
    get_learner_config = function() {
      private$learner = sample_random_learner()
      private$parset = sample_random_config()
      lrn = setHyperPars(private$learner, par.vals = private$parset)
      return(lrn)
    },
    #' Sample a random learner from a set of learners
    #' @return list of one learner with matching parameter set
    #' @export
    sample_random_learner = function() {
      lrn = list_learners(self$task)
      sample(lrn$learners, size = 1, prob = lrn$learner.probs)[[1]]
    },
    #' Sample a random configuration for a selected learner
    #' @param size number of configurations to generate
    #' @return data.frame where each row is one valid configuration
    #'
    #' @export
    sample_random_config = function() {
      des = generateRandomDesign(1, self$par.set, trafo = TRUE)
      des = BBmisc::convertDataFrameCols(des, factors.as.char = TRUE)
      return(des)
    }
  )
)
