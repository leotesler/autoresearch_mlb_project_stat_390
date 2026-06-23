# Evaluate Models with Testing Set

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(themis)

# load data and models ----
load(here("baseline_model/data/mlb_test.rds"))
load(here("final_models/models/lasso_model.rda"))
load(here("final_models/models/bt_model.rda"))

# predictions on testing set ----
mlb_test |> 
  bind_cols(predict(lasso_model, mlb_test)) |> 
  j_index(success, .pred_class)

mlb_test |> 
  bind_cols(predict(bt_model, mlb_test)) |> 
  j_index(success, .pred_class)

# further exploration ----
mlb_test |> 
  bind_cols(predict(lasso_model, mlb_test, type = "prob")) |> 
  select(name, success, .pred_Yes) |> 
  filter(.pred_Yes >= 0.5) |> 
  arrange(desc(.pred_Yes)) |> 
  filter(name == "Aaron Judge") |> 
  print(n = Inf)
