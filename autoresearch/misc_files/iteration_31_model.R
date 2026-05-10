# Run Model with AutoResearch

# load libraries ----
library(tidyverse)
library(tidymodels)
library(themis)

# fixed tuning value required by the loop instructions ----
penalty_value <- 0.00599

# model functions ----
build_recipe <- function(training_data) {
  recipe(success ~ ., training_data) |> 
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
      aa_aaa_ops_delta = ops_aaa - ops_aa
    ) |> 
    step_indicate_na(all_predictors()) |> 
    step_impute_median(all_predictors()) |> 
    step_normalize(all_numeric_predictors()) |> 
    step_zv(all_predictors()) |> 
    step_downsample(success)
}

build_model_spec <- function() {
  logistic_reg(penalty = penalty_value, mixture = 1) |> 
    set_engine("glmnet") |> 
    set_mode("classification")
}
