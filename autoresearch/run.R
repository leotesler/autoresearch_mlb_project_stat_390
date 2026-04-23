# Run prepare.R and model.R scripts

# source scripts ----
source("autoresearch/prepare.R")
source("autoresearch/model.R")

# set seed ----
set.seed(99)

# run model ----
args <- commandArgs(trailingOnly = TRUE)
description <- args[1]

wflow <- workflow() |> 
  add_recipe(
    build_recipe(mlb_train)
  ) |> 
  add_model(
    build_model_spec()
  )

j <- evaluate_model(wflow) 
cat("j_index:", round(j, 6), "\n")
log_result(description, j)

