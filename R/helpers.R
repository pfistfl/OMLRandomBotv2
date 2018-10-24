#' Either loads of creates a registry
load_or_create_registry = function(regname = "bot_registry", overwrite = FALSE,
  source.packages = c("mlr", "data.table"), source.files) {
  if (overwrite)
    unlink(regname, recursive = TRUE)

  if (!dir.exists(regname)) {
    reg = makeExperimentRegistry(
      regname,
      packages = source.packages,
      source = source.files)
  } else {
    reg = loadRegistry(regname, writeable = TRUE)
  }
}