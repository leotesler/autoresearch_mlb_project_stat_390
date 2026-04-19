# Define MLB Success based on EDA

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)

# load data ----
load(here("clean_data/mlb_full.rds"))

# determine success ----
# just making it to MLB
mlb_full |> 
  mutate(success = if_else(n_seasons > 0, TRUE, FALSE)) |> 
  summarize(success_prop = sum(success)/n())

# playing 3+ seasons in MLB
mlb_full |> 
  mutate(success = if_else(n_seasons >= 3, TRUE, FALSE)) |> 
  summarize(success_prop = sum(success)/n())

# plot WAR ----
mlb_full |> 
  filter(n_seasons > 0) |> 
  ggplot(aes(x = war_162)) +
  geom_histogram()

mlb_full |> 
  filter(n_seasons > 0) |> 
  ggplot(aes(x = median_war)) +
  geom_histogram()

# Experiment with success thresholds ----
mlb_full |> 
  filter(avg_war >= 1 | (war_162 > 1.5 & n_seasons >= 5)) |> 
  select(name, war_162, median_war, n_seasons) |> 
  arrange(desc(war_162)) |> 
  print(n = Inf)

# Add success ----
mlb_full <- mlb_full |> 
  mutate(
    across(c("avg_war", "war_162", "n_seasons"), ~if_else(is.na(.x), 0, .x)),
    success = if_else(
      (avg_war >= 1 | (war_162 > 1.5 & n_seasons >= 5)),
      "Yes", "No"
    )
  )

# save results ----
save(mlb_full, file = "clean_data/mlb_full.rds")
