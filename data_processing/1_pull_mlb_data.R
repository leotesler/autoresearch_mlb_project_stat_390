# Pull MLB Data from Fangraphs

# load libraries ----
library(tidyverse)
library(here)
library(httr)
library(rvest)
library(jsonlite)
library(baseballr)

# load MiLB data ----
load(here("clean_data/milb_full.rds"))

# get data ----
fg_data <- bind_rows(
  fg_batter_leaders(startseason = 2013, endseason = 2013),
  fg_batter_leaders(startseason = 2014, endseason = 2014),
  fg_batter_leaders(startseason = 2015, endseason = 2015),
  fg_batter_leaders(startseason = 2016, endseason = 2016),
  fg_batter_leaders(startseason = 2017, endseason = 2017),
  fg_batter_leaders(startseason = 2018, endseason = 2018),
  fg_batter_leaders(startseason = 2019, endseason = 2019),
  fg_batter_leaders(startseason = 2020, endseason = 2020),
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
            avg_war = mean(war, na.rm = TRUE),
            tot_war = sum(war),
            median_war = median(war),
            season_min = min(season_min),
            season_max = max(season_max),
            .groups = "drop") |> 
  mutate(war_162 = (tot_war/tot_games)*162) |> 
  filter(season_min >= 2015)

# join data ----
mlb_full <- milb_full |> 
  left_join(
    mlb_clean,
    by = join_by(x_mlbamid)
  ) |> 
  select(!player_name) |> 
  mutate(across(starts_with("pa"), ~replace_na(.x, 0)),
         milb_pa = pa_aaa+pa_aa+pa_ha+pa_la+pa_r,
         across(starts_with("pa"), ~if_else(.x == 0, NA, .x))) |> 
  filter(milb_pa >= 10) |> 
  select(!c("milb_pa", "season_min", "season_max"))

# save data ----
dir.create("clean_data")

save(mlb_full, file = "clean_data/mlb_full.rds")
