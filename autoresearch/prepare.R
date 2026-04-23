# Prepare Metrics for AutoResearch

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# load training data and folds ----
load(here("baseline_model/data/mlb_train.rds"))
load(here("baseline_model/data/mlb_folds.rda"))

# set up parallel processing ----
registerDoMC(cores = detectCores(logical = TRUE))

# model evaluation function ----
evaluate_model <- function(workflow) {
  results <- fit_resamples(
    workflow,
    mlb_folds,
    metrics = metric_set(j_index, roc_auc, accuracy),
    control = control_resamples(save_pred = FALSE, save_workflow = TRUE)
  )
  
  results |> 
    collect_metrics() |> 
    filter(.metric == "j_index") |> 
    pull(mean)
}

# log result function ----
log_result <- function(description, j) {
  row <- tibble(
    iteration = nrow(read.csv("results.csv")) + 1,
    description = description,
    j_index = round(j, 6),
    timestamp = as.character(Sys.time())
  )
  
  write.table(
    row,
    file = "results.csv",
    sep = ",",
    append = TRUE,
    row.names = FALSE,
    col.names = !file.exists("results.csv")
  )
}
