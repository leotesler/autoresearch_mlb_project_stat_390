# Fit Baseline Model to Folds

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)

# load data ----
load(here("baseline_model/data/mlb_train.rds"))
load(here("baseline_model/data/mlb_folds.rda"))

# set seed ----
set.seed(99)

# handle common conflicts ----
tidymodels_prefer()

# parallel processing ----
registerDoMC(cores = detectCores())

# model specifications
lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) |> 
  set_engine("glmnet") |> 
  set_mode("classification")

# recipe ----
lasso_rec <- recipe(success ~ ., mlb_train) |> 
  step_rm(x_mlbamid, name) |> 
  step_normalize(all_predictors()) |> 
  step_zv(all_predictors())

# define workflow ----
lasso_wflow <- workflow() |> 
  add_model(lasso_spec) |> 
  add_recipe(lasso_rec)

# hyperparameter tuning ----
lasso_params <- extract_parameter_set_dials(lasso_spec)

lasso_grid <- grid_regular(lasso_params, levels = 10)

# fit to folds ----
lasso_tuned <- tune_grid(
  lasso_wflow,
  mlb_folds,
  grid = lasso_grid,
  metrics = metric_set(roc_auc, accuracy),
  control = control_grid(save_workflow = TRUE)
)

# save results ----
dir.create("baseline_model/results")

save(lasso_tuned, file = "baseline_model/results/lasso_tuned.rda")
