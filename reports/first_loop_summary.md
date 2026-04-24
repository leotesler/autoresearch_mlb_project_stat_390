---
title: "first_loop_summary"
output: html_document
---

• The loop has now met its stopping condition and should stop here.

  Best result: j_index = 0.824185, first reached at iteration 31 in autoresearch/results.csv. I restored
  autoresearch/model.R:1 to that best-performing state.

  What helped:

  - Upper-minors weighted age-adjusted summaries were the first real improvement driver.
  - The strongest gains came from explicit power-shape features: weighted ISO, HR/FB, FB%, ISO x FB%, and AA-
    to-AAA deltas on those signals.
  - A modest final lift came from adding upper-minors BB% - K% and its AA-to-AAA delta.

  What did not help:

  - SMOTE
  - Broad all-level age adjustments
  - High-A transition features
  - Most interactions
  - SLG, OBP, wOBA, spray/batted-ball alternates, exposure-weighted power-shape, and HR/FB - SWSTR%

  Stopping-rule basis:

  - The last improvement of at least +0.001 over the prior threshold-resetting best was iteration 28
    (0.824161 vs 0.82313).
  - Iterations 29 through 38 then failed to improve by at least 0.001, giving 10 consecutive non-qualifying
    iterations.

  Recommended external data to explore next:

  - Draft round / overall pick
  - Signing bonus / international FA status
  - Age at pro debut
  - Defensive position spectrum / primary position
  - Prospect rankings from public sources like Baseball America, FanGraphs, or MLB Pipeline