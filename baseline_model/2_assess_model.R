# Assess Baseline Model

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)

# load data and tuning results ----
load(here("baseline_model/data/mlb_train.rds"))
load(here("baseline_model/data/mlb_test.rds"))
load(here("baseline_model/results/lasso_tuned.rda"))

# print tuning results ----
lasso_tuned |> 
  show_best(metric = "roc_auc")

autoplot(lasso_tuned)

# get best workflow ----
optimal_wflow <- lasso_tuned |> 
  extract_workflow() |> 
  finalize_workflow(select_best(lasso_tuned, metric = "roc_auc"))

# fit best model ----
baseline_model <- fit(optimal_wflow, mlb_train)

# assess best model ----
mlb_test |> 
  bind_cols(predict(baseline_model, mlb_test, type = "prob")) |> 
  roc_auc(success, .pred_No)
