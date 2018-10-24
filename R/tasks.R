library(OpenML)
cc18 = listOMLTasks(tag = "OpenML-CC18")
task.ids = cc18$task.id[1:4]


#' Get a task name from a task.id
get_task_name = function(task.id) {
  cc18[cc18$task.id == task.id, "name"]
}

#' Get task metadata
get_task_metadata = function(task) {
  md = list(p = 1, n = 1)
  if (is.null(task)) {
    md$p = getTaskNFeats(task)
    md$n = getTaskSize(task)
  }
  return(md)
}


