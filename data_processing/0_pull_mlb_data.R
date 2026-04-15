# Pull MLB Data from Fangraphs

# load libraries ----
library(tidyverse)
library(here)
library(baseballr)

# get data ----
fg_data <- bind_rows(
  fg_batter_leaders(startseason = 2021, endseason = 2021),
  fg_batter_leaders(startseason = 2022, endseason = 2022),
  fg_batter_leaders(startseason = 2023, endseason = 2023),
  fg_batter_leaders(startseason = 2024, endseason = 2024),
  fg_batter_leaders(startseason = 2025, endseason = 2025)
) |> 
  janitor::clean_names()

# aggregate data ----
mlb_clean <- fg_data |> 
  group_by(x_mlbamid, player_name) |> 
  summarize(n_seasons = n(),
            tot_games = sum(g),
            tot_war = sum(war),
            median_war = median(war),
            .groups = "drop") |> 
  mutate(war_162 = (tot_war/tot_games)*162)

# save data ----
dir.create("clean_data")

save(mlb_clean, file = "clean_data/mlb_full.rds")
