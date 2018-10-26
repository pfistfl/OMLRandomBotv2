library(OpenML)
cc18 = listOMLTasks(tag = "OpenML-CC18")
task.ids = cc18$task.id[1:4]


#' Get a task name from a task.id
get_task_name = function(task.id) {
  cc18[cc18$task.id == task.id, "name"]
}

#' Get task metadata
#' @param oml.task [OMLTask] a OpenML Task.
#' @return [list] named list of metafeatures
get_task_metadata = function(oml.task = NULL) {
  # Return some defaults, just make sure we can construct the paramset without
  # a task.
  md = list(p = 20, n = 100)
  if (!is.null(oml.task)) {
    task = convertOMLTaskToMlr(oml.task)$mlr.task
    md$p = getTaskNFeats(task)
    # n is the number of points in the training data.
    # take the minimum over CV splits.
    md$n = min(sapply(oml.task$mlr.rin$train.inds, length))
  }
  return(md)
}


