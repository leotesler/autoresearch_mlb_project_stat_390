# Run Model with AutoResearch

# load libraries ----
library(tidyverse)
library(tidymodels)
library(themis)

# load baseline tuning results ----
load(here("baseline_model/results/lasso_tuned.rda"))

# get best penalty value ----
best_penalty <- lasso_tuned |> 
  select_best(metric = "j_index") |> 
  pull(penalty)

# model functions ----
build_recipe <- function(training_data) {
  recipe(success ~ ., training_data) |> 
    step_rm(x_mlbamid, name) |> 
    step_indicate_na(all_predictors()) |> 
    step_impute_median(all_predictors()) |> 
    step_normalize(all_numeric_predictors()) |> 
    step_zv(all_predictors()) |> 
    step_downsample(success)
}

build_model_spec <- function() {
  logistic_reg(penalty = best_penalty, mixture = 1) |> 
    set_engine("glmnet") |> 
    set_mode("classification")
}
