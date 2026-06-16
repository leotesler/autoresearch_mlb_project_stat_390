# Fit Lasso Model with Best AutoResearch Iteration

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(doMC)
library(themis)

# load training data and folds ----
load(here("baseline_model/data/mlb_folds.rda"))
load(here("baseline_model/data/mlb_train.rds"))

# handle common conflicts ----
tidymodels_prefer()

# set seed ----
set.seed(99)

# parallel processing ----
registerDoMC(cores = detectCores())

# recipe ----
lasso_rec <- recipe(success ~ ., mlb_train) |> 
  step_rm(x_mlbamid, name) |> 
  step_mutate(
    upper_minors_wrc = (w_rc_aa * log1p(pa_aa) + w_rc_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_ops = (ops_aa * log1p(pa_aa) + ops_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_bb_k = (bb_k_aa * log1p(pa_aa) + bb_k_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_bb = (bb_percent_aa * log1p(pa_aa) + bb_percent_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_k = (k_percent_aa * log1p(pa_aa) + k_percent_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_swstr = (sw_str_percent_aa * log1p(pa_aa) + sw_str_percent_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_babip = (babip_aa * log1p(pa_aa) + babip_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_iso = (iso_aa * log1p(pa_aa) + iso_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_hr_fb = (hr_fb_aa * log1p(pa_aa) + hr_fb_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_fb = (fb_percent_aa * log1p(pa_aa) + fb_percent_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_power_shape = upper_minors_iso * upper_minors_fb,
    upper_minors_bb_minus_k = upper_minors_bb - upper_minors_k,
    upper_minors_age = (min_age_aa * log1p(pa_aa) + min_age_aaa * log1p(pa_aaa)) / (log1p(pa_aa) + log1p(pa_aaa) + 1e-3),
    upper_minors_wrc_per_age = upper_minors_wrc / upper_minors_age,
    upper_minors_ops_per_age = upper_minors_ops / upper_minors_age,
    upper_minors_bb_per_age = upper_minors_bb / upper_minors_age,
    upper_minors_k_per_age = upper_minors_k / upper_minors_age,
    upper_minors_swstr_per_age = upper_minors_swstr / upper_minors_age,
    upper_minors_babip_per_age = upper_minors_babip / upper_minors_age,
    upper_minors_iso_per_age = upper_minors_iso / upper_minors_age,
    upper_minors_hr_fb_per_age = upper_minors_hr_fb / upper_minors_age,
    upper_minors_fb_per_age = upper_minors_fb / upper_minors_age,
    upper_minors_power_shape_per_age = upper_minors_power_shape / upper_minors_age,
    upper_minors_bb_minus_k_per_age = upper_minors_bb_minus_k / upper_minors_age,
    aa_aaa_hr_fb_delta = hr_fb_aaa - hr_fb_aa,
    aa_aaa_fb_delta = fb_percent_aaa - fb_percent_aa,
    aa_aaa_power_shape_delta = (iso_aaa * fb_percent_aaa) - (iso_aa * fb_percent_aa),
    aa_aaa_bb_minus_k_delta = (bb_percent_aaa - k_percent_aaa) - (bb_percent_aa - k_percent_aa),
    aa_aaa_wrc_per_age_delta = (w_rc_aaa / min_age_aaa) - (w_rc_aa / min_age_aa),
    aa_aaa_ops_per_age_delta = (ops_aaa / min_age_aaa) - (ops_aa / min_age_aa),
    aa_aaa_wrc_delta = w_rc_aaa - w_rc_aa,
    aa_aaa_iso_delta = iso_aaa - iso_aa,
    aa_aaa_bb_delta = bb_percent_aaa - bb_percent_aa,
    aa_aaa_k_delta = k_percent_aaa - k_percent_aa,
    aa_aaa_age_delta = min_age_aaa - min_age_aa,
    aa_aaa_pa_delta = pa_aaa - pa_aa,
    aa_aaa_ops_delta = ops_aaa - ops_aa,
    log_iso_aa = log1p(pmax(iso_aa, 0)),
    log_iso_aaa = log1p(pmax(iso_aaa, 0)),
    log_hr_aa = log1p(hr_aa),
    log_hr_aaa = log1p(hr_aaa),
    log_fb_aa = log1p(pmax(fb_percent_aa, 0)),
    log_fb_aaa = log1p(pmax(fb_percent_aaa, 0)),
    la_ha_iso_delta = iso_ha - iso_la,
    la_ha_hr_fb_delta = hr_fb_ha - hr_fb_la,
    la_ha_fb_delta = fb_percent_ha - fb_percent_la,
    la_ha_power_shape_delta = (iso_ha * fb_percent_ha) - (iso_la * fb_percent_la),
    la_ha_bb_minus_k_delta = (bb_percent_ha - k_percent_ha) - (bb_percent_la - k_percent_la),
    la_ha_wrc_delta = w_rc_ha - w_rc_la,
    la_ha_ops_delta = ops_ha - ops_la,
    la_ha_wrc_per_age_delta = (w_rc_ha / min_age_ha) - (w_rc_la / min_age_la),
    r_la_iso_delta = iso_la - iso_r,
    r_la_hr_fb_delta = hr_fb_la - hr_fb_r,
    r_la_fb_delta = fb_percent_la - fb_percent_r,
    r_la_power_shape_delta = (iso_la * fb_percent_la) - (iso_r * fb_percent_r),
    r_la_bb_minus_k_delta = (bb_percent_la - k_percent_la) - (bb_percent_r - k_percent_r),
    r_la_wrc_delta = w_rc_la - w_rc_r,
    r_la_ops_delta = ops_la - ops_r,
    r_la_wrc_per_age_delta = (w_rc_la / min_age_la) - (w_rc_r / min_age_r),
    ha_aa_iso_delta = iso_aa - iso_ha,
    ha_aa_hr_fb_delta = hr_fb_aa - hr_fb_ha,
    ha_aa_fb_delta = fb_percent_aa - fb_percent_ha,
    ha_aa_power_shape_delta = (iso_aa * fb_percent_aa) - (iso_ha * fb_percent_ha),
    ha_aa_bb_minus_k_delta = (bb_percent_aa - k_percent_aa) - (bb_percent_ha - k_percent_ha),
    ha_aa_wrc_delta = w_rc_aa - w_rc_ha,
    ha_aa_ops_delta = ops_aa - ops_ha,
    ha_aa_wrc_per_age_delta = (w_rc_aa / min_age_aa) - (w_rc_ha / min_age_ha),
    upper_def_inn = coalesce(inn_c_aa, 0) + coalesce(inn_c_aaa, 0) + coalesce(inn_ss_aa, 0) + coalesce(inn_ss_aaa, 0) + coalesce(inn_cf_aa, 0) + coalesce(inn_cf_aaa, 0) + coalesce(inn_2b_aa, 0) + coalesce(inn_2b_aaa, 0) + coalesce(inn_3b_aa, 0) + coalesce(inn_3b_aaa, 0) + coalesce(inn_rf_aa, 0) + coalesce(inn_rf_aaa, 0) + coalesce(inn_lf_aa, 0) + coalesce(inn_lf_aaa, 0) + coalesce(inn_1b_aa, 0) + coalesce(inn_1b_aaa, 0),
    upper_premium_inn = coalesce(inn_c_aa, 0) + coalesce(inn_c_aaa, 0) + coalesce(inn_ss_aa, 0) + coalesce(inn_ss_aaa, 0) + coalesce(inn_cf_aa, 0) + coalesce(inn_cf_aaa, 0),
    upper_corner_inn = coalesce(inn_1b_aa, 0) + coalesce(inn_1b_aaa, 0) + coalesce(inn_lf_aa, 0) + coalesce(inn_lf_aaa, 0) + coalesce(inn_rf_aa, 0) + coalesce(inn_rf_aaa, 0),
    upper_infield_inn = coalesce(inn_2b_aa, 0) + coalesce(inn_2b_aaa, 0) + coalesce(inn_3b_aa, 0) + coalesce(inn_3b_aaa, 0) + coalesce(inn_ss_aa, 0) + coalesce(inn_ss_aaa, 0),
    upper_outfield_inn = coalesce(inn_lf_aa, 0) + coalesce(inn_lf_aaa, 0) + coalesce(inn_cf_aa, 0) + coalesce(inn_cf_aaa, 0) + coalesce(inn_rf_aa, 0) + coalesce(inn_rf_aaa, 0),
    upper_premium_share = upper_premium_inn / (upper_def_inn + 1),
    upper_corner_share = upper_corner_inn / (upper_def_inn + 1),
    upper_infield_share = upper_infield_inn / (upper_def_inn + 1),
    upper_outfield_share = upper_outfield_inn / (upper_def_inn + 1),
    upper_spectrum_score = (2.5 * (coalesce(inn_c_aa, 0) + coalesce(inn_c_aaa, 0)) + 2.0 * (coalesce(inn_ss_aa, 0) + coalesce(inn_ss_aaa, 0)) + 1.2 * (coalesce(inn_cf_aa, 0) + coalesce(inn_cf_aaa, 0)) + 0.8 * (coalesce(inn_2b_aa, 0) + coalesce(inn_2b_aaa, 0) + coalesce(inn_3b_aa, 0) + coalesce(inn_3b_aaa, 0)) - 0.4 * (coalesce(inn_lf_aa, 0) + coalesce(inn_lf_aaa, 0) + coalesce(inn_rf_aa, 0) + coalesce(inn_rf_aaa, 0)) - 1.0 * (coalesce(inn_1b_aa, 0) + coalesce(inn_1b_aaa, 0))) / (upper_def_inn + 1),
    upper_chances = coalesce(putouts_c_aa, 0) + coalesce(putouts_c_aaa, 0) + coalesce(putouts_ss_aa, 0) + coalesce(putouts_ss_aaa, 0) + coalesce(putouts_cf_aa, 0) + coalesce(putouts_cf_aaa, 0) + coalesce(putouts_2b_aa, 0) + coalesce(putouts_2b_aaa, 0) + coalesce(putouts_3b_aa, 0) + coalesce(putouts_3b_aaa, 0) + coalesce(putouts_rf_aa, 0) + coalesce(putouts_rf_aaa, 0) + coalesce(putouts_lf_aa, 0) + coalesce(putouts_lf_aaa, 0) + coalesce(putouts_1b_aa, 0) + coalesce(putouts_1b_aaa, 0) + coalesce(assists_c_aa, 0) + coalesce(assists_c_aaa, 0) + coalesce(assists_ss_aa, 0) + coalesce(assists_ss_aaa, 0) + coalesce(assists_cf_aa, 0) + coalesce(assists_cf_aaa, 0) + coalesce(assists_2b_aa, 0) + coalesce(assists_2b_aaa, 0) + coalesce(assists_3b_aa, 0) + coalesce(assists_3b_aaa, 0) + coalesce(assists_rf_aa, 0) + coalesce(assists_rf_aaa, 0) + coalesce(assists_lf_aa, 0) + coalesce(assists_lf_aaa, 0) + coalesce(assists_1b_aa, 0) + coalesce(assists_1b_aaa, 0),
    upper_range_factor_9 = 9 * upper_chances / (upper_def_inn + 1),
    upper_power_spectrum = upper_minors_power_shape * upper_spectrum_score,
    upper_control_spectrum = upper_minors_bb_minus_k * upper_spectrum_score,
    upper_wrc_premium = upper_minors_wrc * upper_premium_share,
    upper_power_corner = upper_minors_power_shape * upper_corner_share
  ) |> 
  step_rm(matches("^upper_minors_")) |> 
  step_rm(debut_age, amateur_type) |> 
  step_rm(matches("^(inn|putouts|assists)_")) |> 
  step_indicate_na(all_predictors()) |> 
  step_impute_median(all_predictors()) |> 
  step_zv(all_predictors()) |> 
  step_normalize(all_numeric_predictors()) |> 
  step_smote(success)

# model specification ----
lasso_spec <- logistic_reg(penalty = tune(), mixture = 1) |> 
  set_engine("glmnet") |> 
  set_mode("classification")

# define workflow ----
lasso_wflow <- workflow() |> 
  add_model(lasso_spec) |> 
  add_recipe(lasso_rec)

# hyperparameter tuning ----
lasso_grid <- grid_regular(extract_parameter_set_dials(lasso_spec), levels = 10)

# tune model ----
lasso_tuned <- tune_grid(
  lasso_wflow,
  mlb_folds,
  grid = lasso_grid,
  metrics = metric_set(accuracy, j_index, precision),
  control = control_grid(save_workflow = TRUE)
)

# fit best model ----
optimal_wflow <- lasso_tuned |> 
  extract_workflow() |> 
  finalize_workflow(select_best(lasso_tuned, metric = "j_index"))

lasso_model <- fit(optimal_wflow, mlb_train)

# save best model ----
dir.create("final_models/models")

save(lasso_model, file = "final_models/models/lasso_model.rda")