# Splits and Folds for Baseline Model

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)

# load data ----
load(here("clean_data/mlb_full.rds"))

# set seed ----
set.seed(99)

# remove unnessecary variables ----
mlb_clean <- mlb_full |> 
  select(!starts_with("team")) |> 
  select(!starts_with("player_name")) |> 
  select(!starts_with("season")) |> 
  select(!starts_with("aff_id")) |> 
  select(!starts_with("aff_abb")) |> 
  select(!starts_with("a_level")) |> 
  select(!starts_with("level_")) |> 
  select(!starts_with("playerids")) |> 
  select(!starts_with("minormaster")) |> 
  select(!starts_with("player_team_id")) |> 
  select(!starts_with("position_db")) |> 
  select(!starts_with("max_age")) |> 
  separate(age_aaa, into = c("min_age_aaa", "max_age_aaa"), sep = "-") |> 
  separate(age_aa, into = c("min_age_aa", "max_age_aa"), sep = "-") |> 
  separate(age_ha, into = c("min_age_ha", "max_age_ha"), sep = "-") |> 
  separate(age_la, into = c("min_age_la", "max_age_la"), sep = "-") |> 
  separate(age_r, into = c("min_age_r", "max_age_r"), sep = "-") |> 
  select(!starts_with("max_age")) |> 
  mutate(across(starts_with("min_age"), ~as.numeric(.x)),
         across(where(is.numeric), ~replace_na(.x, 0)),
         success = factor(success)) |> 
  select(!c("n_seasons", "tot_games", "tot_war", "median_war", "war_162"))

mlb_clean |> 
  skimr::skim()

# train-test split ----
mlb_split <- mlb_clean |> 
  initial_split(prop = 0.8, strata = success)

mlb_train <- training(mlb_split)
mlb_test <- testing(mlb_split)

# cross validation ----
mlb_folds <- mlb_train |> 
  vfold_cv(v = 5, repeats = 3, strata = success)

# save results ----
dir.create("baseline_model/data")

save(mlb_train, file = "baseline_model/data/mlb_train.rds")
save(mlb_test, file = "baseline_model/data/mlb_test.rds")
save(mlb_folds, file = "baseline_model/data/mlb_folds.rda")
