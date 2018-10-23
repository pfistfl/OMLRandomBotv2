library(OpenML)
cc18 = listOMLTasks(tag = "OpenML-CC18")

#' sampleRandomTask
#'
#' this draws a random binary classif OMLTask from study 14 with 10 fold CV and without missing values
#' @return OML task
#' @export
sampleRandomTask = function() {

  tasks = listOMLTasks(number.of.classes = 2L, number.of.missing.values = 0,
    data.tag = "OpenML100", estimation.procedure = "10-fold Crossvalidation")
  messagef("Found %i available OML tasks", nrow(tasks))
  task = tasks %>%
    filter(format == "ARFF", status == "active") %>%
    sample_n(1) %>%
    select(task.id, name)

  return(list(id = task$task.id, name = task$name))
}
