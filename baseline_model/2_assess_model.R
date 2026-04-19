# Assess Baseline Model

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(themis)
library(kableExtra)

# load data and tuning results ----
load(here("baseline_model/data/mlb_train.rds"))
load(here("baseline_model/data/mlb_test.rds"))
load(here("baseline_model/results/lasso_tuned.rda"))

# print tuning results ----
lasso_tuned |> 
  show_best(metric = "j_index")

# get best workflow ----
optimal_wflow <- lasso_tuned |> 
  extract_workflow() |> 
  finalize_workflow(select_best(lasso_tuned, metric = "j_index"))

# fit best model ----
baseline_model <- fit(optimal_wflow, mlb_train)

# assess best model ----
mlb_test |> 
  bind_cols(predict(baseline_model, mlb_test)) |> 
  j_index(success, .pred_class)

mlb_test |> 
  bind_cols(predict(baseline_model, mlb_test, type = "prob")) |> 
  filter(.pred_Yes >= 0.5) |> 
  select(name, success, .pred_Yes) |> 
  arrange(desc(.pred_Yes)) |> 
  print(n = Inf)

mlb_test |> 
  bind_cols(predict(baseline_model, mlb_test, type = "prob")) |> 
  select(.pred_Yes) |> 
  print(n = Inf)

# get model coefficients ----
dir.create("images")

baseline_model |> 
  tidy() |> 
  filter(estimate != 0) |> 
  kable("html") |> 
  save_kable(file = "images/coef_table.png")

# save results ----
save(baseline_model, file = "baseline_model/results/baseline_model.rda")
