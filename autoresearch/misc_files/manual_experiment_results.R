# Parse Results of Manual Experiments

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(DT)
library(kableExtra)

# load results ----
results <- read_csv("autoresearch/results.csv")

# create matrix ----
exp_mat <- results |> 
  mutate(delta_best_j = j_index - max(j_index)) |> 
  slice_tail(n = 6) |> 
  mutate(iteration = iteration - 41,
         feature_set = if_else(grepl("baseline", description), "baseline", "best"),
         imbalance_strategy = if_else(grepl("smote", description), "smote", "downsample"),
         delta_base_j = j_index - j_index[iteration == 1]) |> 
  add_column(isolated_var = c(
    "none", "none", "step_smote()", "log ISO/HR/FB", "Low A to High A deltas", "re-tune penalty"
  )) |> 
  select(experiment = iteration, feature_set, imbalance_strategy, isolated_var, j_index, delta_base_j, delta_best_j)

exp_mat |> 
  kable("html") |> 
  save_kable(file = "images/experiment_matrix.png")

exp_mat |> 
  ggplot(aes(x = experiment, y = j_index)) +
  geom_line() + 
  theme_classic() +
  labs(
    title = "J Index Over Time",
    x = "Experiment #",
    y = "J Index"
  )

ggsave(filename = "images/metric_over_time.png")

results |> 
  slice_tail(n = 6)
