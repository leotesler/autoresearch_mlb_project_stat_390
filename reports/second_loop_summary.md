---
title: "second_loop_summary"
output: html_document
---

### Best result

  - Best j_index: 0.838587
  - Best logged iteration: 68
  - Description: Rookie-to-LowA early power/discipline/age-adjusted progression added to the prior best SMOTE
    recipe.

### What helped

  - SMOTE with tuned lasso over the iteration-31 feature set: 0.827846
  - Upper-minors defensive spectrum/range features: improved to 0.828994
  - Log ISO/HR/FB transforms + Low-A → High-A progression deltas: large jump to 0.836954
  - High-A → AA progression deltas: improved to 0.838531
  - Rookie → Low-A progression deltas: tiny improvement to final best, 0.838587

### What did not help

  - Raw fielding variables were noisy; removing them helped stabilize the recipe.
  - Career-wide defensive spectrum/progression features dropped to 0.832840.
  - Position-specific defensive share interactions dropped to 0.833152.
  - Downsampling the best feature set dropped badly to 0.820807.
  - SMOTE with neighbors = 3 dropped to 0.834896.

  ### Final model.R state

  The final model:

  - Keeps the iteration-31 upper-minors offensive/age-adjusted features.
  - Adds log transforms for AA/AAA ISO, HR, and FB%.
  - Adds Rookie→Low-A, Low-A→High-A, High-A→AA, and AA→AAA progression deltas.
  - Adds upper-minors defensive spectrum/range/share features.
  - Removes raw inn_*, putouts_*, and assists_* fielding columns after deriving defensive features.
  - Uses step_smote(success) and logistic_reg(penalty = tune(), mixture = 1).

  ### Recommended external data for next loop

  - Draft round / overall pick / signing bonus.
  - Amateur source: college vs high school vs international.
  - Age at signing and age at pro debut.
  - Prospect-list rankings or FV grades.
  - Injury history / missed-season indicators.