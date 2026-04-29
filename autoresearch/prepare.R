# Prepare Metrics for AutoResearch

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(themis)

# load training data and folds ----
load(here("baseline_model/data/mlb_train.rds"))
load(here("baseline_model/data/mlb_folds.rda"))

# set up parallel processing ----
registerDoMC(cores = detectCores(logical = TRUE))

# model evaluation function ----
evaluate_model <- function(workflow) {
  results <- tune_grid(
    workflow,
    mlb_folds,
    grid = grid_regular(extract_parameter_set_dials(workflow), levels = 10),
    metrics = metric_set(j_index, accuracy, roc_auc),
    control = control_grid(save_pred = FALSE, save_workflow = TRUE)
  )
  
  results |> 
    #collect_metrics() |> 
    #filter(.metric == "j_index") |> 
    show_best(metric = "j_index", n = 1) |> 
    pull(mean)
}

# log result function ----
log_result <- function(description, j) {
  row <- tibble(
    iteration = if (file.exists("autoresearch/results.csv")) nrow(read.csv("autoresearch/results.csv")) + 1 else 1,
    description = description,
    j_index = round(j, 6),
    timestamp = as.character(Sys.time())
  )
  
  write.table(
    row,
    file = "autoresearch/results.csv",
    sep = ",",
    append = TRUE,
    row.names = FALSE,
    col.names = !file.exists("autoresearch/results.csv")
  )
}
