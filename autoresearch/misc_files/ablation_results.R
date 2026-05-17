# Ablation results

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)

# load results ----
results <- read_csv(here("autoresearch/results.csv"))

# create ablation table ----
total_gain <- as.numeric(results$j_index[results$iteration == 58]) - as.numeric(results$j_index[results$iteration == 1])

results |> 
  filter(iteration == 58 | grepl("ablation", description)) |> 
  mutate(description = if_else(iteration == 58, "current best model", description),
         j_index = as.numeric(j_index),
         j_index_drop = j_index[iteration == 58] - j_index,
         pct_gain_explained = j_index_drop/total_gain) |> 
  select(model = description, j_index, j_index_drop, pct_gain_explained)
