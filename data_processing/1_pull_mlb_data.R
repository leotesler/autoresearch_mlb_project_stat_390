# Pull MLB Data from Fangraphs

# load libraries ----
library(tidyverse)
library(here)
library(httr)
library(rvest)
library(jsonlite)

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
            tot_war = sum(war),
            median_war = median(war),
            .groups = "drop") |> 
  mutate(war_162 = (tot_war/tot_games)*162)

# join data ----
mlb_full <- milb_full |> 
  left_join(
    mlb_clean,
    by = join_by(x_mlbamid)
  ) |> 
  select(!player_name) |> 
  mutate(across(where(is.numeric), ~replace_na(.x, 0)),
         milb_pa = pa_aaa+pa_aa+pa_ha+pa_la+pa_r) |> 
  filter(milb_pa >= 10) |> 
  select(!milb_pa)

# save data ----
dir.create("clean_data")

save(mlb_full, file = "clean_data/mlb_full.rds")
