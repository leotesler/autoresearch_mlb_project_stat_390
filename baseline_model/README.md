---
title: "README"
output: html_document
---

Subdirectories:

`data/`: Training/testing split and cross-validation set.

`results/`: Tuning results and baseline model.

R scripts:

`0_splits_folds.R`: Final clean, split, and cross-validation of raw dataset.

`1_fit_model.R`: Model specification, recipe, and hyperparameter tuning of lasso model.

`2_assess_model.R`: Evaluation of tuning results and fitting of best model for baseline.
