#' Either loads of creates a registry
load_or_create_registry = function(regname = "bot_registry", overwrite = FALSE,
  source.pkgs = c("mlr", "data.table"), source.files) {
  if (overwrite)
    unlink(regname, recursive = TRUE)

  if (!dir.exists(regname)) {
    reg = batchtools::makeExperimentRegistry(
      regname,
      packages = source.pkgs,
      source = source.files)
  } else {
    reg = batchtools::loadRegistry(regname, writeable = TRUE)
  }
}
