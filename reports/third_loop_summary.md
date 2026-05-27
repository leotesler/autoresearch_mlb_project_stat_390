---
title: "third_loop_summary"
output: html_document
---

• Full-auto loop complete.

  - Best j_index: 0.845966
  - Best iteration: 60 (ablation: remove upper minors weighted summary variables)
  - Confirmed/reproduced: iterations 68 and 70 also produced 0.845966
  - Stopping reason: no improvement of at least 0.001 over the best result for 10 consecutive iterations
    after iteration 60.

  What helped:

  - Removing upper-minors weighted summary variables while keeping derived interaction features based on
    them.
  - Keeping defensive-spectrum engineered features:
      - upper_spectrum_score
      - upper_range_factor_9
      - upper_power_spectrum
      - upper_control_spectrum
      - upper_wrc_premium
      - upper_power_corner

  What did not help:

  - Raw debut_age + amateur_type dummies: 0.842483
  - Debut-age/amateur-type interaction features: 0.844769
  - Debut-age fast-track interactions only: 0.836074
  - Earlier ablations removing AA→AAA deltas, log transforms, lower-minors deltas, or defensive variables all
    reduced performance.

  Final model.R has been restored to the best-performing recipe:

  - keeps iteration-60-style feature set,
  - removes debut_age and amateur_type,
  - removes raw fielding columns after defensive feature construction,
  - uses step_smote(success),
  - preserves mixture = 1,
  - exposes only build_recipe() and build_model_spec().

  Recommended next external data sources:

  - MLB draft round / overall pick from MLB draft databases or Baseball-Reference.
  - Signing bonus data from Baseball America.
  - Prospect rankings by year from Baseball America / MLB Pipeline.
  - Age-relative league context or park-adjusted minor-league factors if available.