#-----------------------------------------------------------------------------------------
#' R6-Class OMLBot
#'
#' Public Members:
#' task.id [character(1)]
#' task [Task]
#'
#' initialize [function(task.id)]: instantiate a new bot with a given oml task.id
#' run [function(timeout)] : draw random learner/config and run the bot
#'
#' Private Members:
#' learner [learner]
#' parset [ParamSet]
#' pars [list]
#'
#' get_learner_and_config [function()]
#' run_internal [function()]
OMLBot = R6::R6Class("OMLBot",

  public = list(
    task.id = NULL,
    filepath = NULL,
    oml.task = NULL,
    task = NULL,
    learner = NULL,
    timeout = NULL,


    initialize = function(task.id) {
      self$task.id = task.id
    },
    run = function (timeout = NULL, max.memory = NULL) {
      # Set timeout
      self$timeout = ifelse(is.null(timeout), Inf, assert_integerish(timeout))
      self$oml.task = self$get_oml_task()
      self$task = OpenML::convertOMLTaskToMlr(self$oml.task)$mlr.task
      self$learner = private$get_learner_and_config()
      self$learner = private$add_learner_wrappers()
      measures = private$get_measures()
      # Run training in a separate process with a specified timeout
      callr::r(private$run_internal, args = list(oml.task = self$oml.task, lrn = private$learner, measures = measures),
        timeout = self$timeout)
    }
  ),

  private = list(
    learner = NULL,
    parset = NULL,
    pars = NULL,
    get_learner_and_config = function() {makeLearner("classif.rpart", predict.type = "prob")},
    add_learner_wrappers = function() {self$learner},
    get_task_oml = function() {
      if (is.null(self$filepath)) {
        OpenML::getOMLTask(as.numeric(self$task.id))
      } else {
        readRDS(self$filepath)
      }
    },
    run_internal = function(oml.task, lrn, measures) {
      options("mlr.show.info" = TRUE)
      OpenML::runTaskMlr(task = oml.task, learner = lrn, measures = measures)
    },
    )
)

#-----------------------------------------------------------------------------------------
#' R6-Class OMLRandomBot
#'
#' inherits from [OMLBot]
#' Public Members:
#' < inherited >
#'
#' Private Members:
#'
#' get_learner_and_config [function()]
#' sample_random_learner [function()]
#' get_learner_parset [function()]
#' sample_random_config [function()]
#'
OMLRandomBot = R6::R6Class("OMLRandomBot",
  inherit = OMLBot,

  public = list(),

  private = list(
    #' Sample random learner and hyperpars, return configured learner
    #' @return learner with matching parameter set
    get_learner_and_config = function() {
      private$learner = private$sample_random_learner()
      private$parset  = private$get_learner_parset()
      private$pars    = private$sample_random_config()
      lrn = setHyperPars(private$learner, par.vals = private$pars)
      lrn = wrapLearner(lrn)
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
      get_parset(private$learner, self$oml.task)
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
      # No measures that require binary class if task is multiclass.
      measures = intersect(measures, listMeasures(self$task, create = TRUE))
      return(measures)
    },
    wrap_learner = function() {
      lrn = self$learner
      # factors -> dummies
      if (!("factors" %in% getLearnerProperties(self$learner)))
        lrn = makeDummyFeaturesWrapper(lrn)
        # FIXME: ? removeConstantFeatures
        # FIXME: ? Impute
      return(lrn)
    }
  )
)
