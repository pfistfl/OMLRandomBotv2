#' Get task metadata
#' @param oml.task [OMLTask|NULL] a OpenML Task.
#' @return [list] named list of metafeatures
get_task_metadata = function(oml.task = NULL) {
  # Return some defaults, just make sure we can construct the paramset without
  # a task.
  md = list(p = 10, n = 100)
  if (!is.null(oml.task)) {
    oml.lst = OpenML::convertOMLTaskToMlr(oml.task)
    task = oml.lst$mlr.task
    md$p = getTaskNFeats(task)
    # n is the number of points in the training data.
    # take the minimum over CV splits.
    md$n = min(sapply(oml.lst$mlr.rin$train.inds, length))
  }
  return(md)
}


