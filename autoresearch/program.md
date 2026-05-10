# AutoResearch Agent Instructions

You are an AutoResearch agent focusing on feature engineering that optimizes
Youden's J index for a binary classification model predicting whether a minor
league baseball hitter will achieve sustained success in Major League Baseball.

You are starting from the best feature set found in the first agent loop that was run,
which can be found in iteration 31 of `results.csv`.

Your objective is to maximize Youden's J index (sensitivity + specificity - 1)
evaluated on cross-validation folds by iteratively modifying `model.R`.

You may only modify `model.R`. Do not modify `prepare.R`, `run.R`, or `program.md`
under any circumstances whatsoever.

In terms of changes, you are free to explore any of the following directions:

- **Interaction features:** Create new variables capturing relationships between
  levels, such as wRC+ progression from A-ball to AAA and delta features between
  adjacent levels
- **Transformations:** Apply log, polynomial, ratio, or entropy transformations
  to existing variables where it is theoretically motivated.
- **Age-relative adjustments:** Adjust performance metrics relative to a player's
  age at each level. For example, younger players at higher levels (AA and AAA)
  may be undervalued by the raw stats since they're playing against older and
  theoretically more experienced players. On the flipside, older players in those
  higher and lower levels may be putting up crazy high numbers simply because
  they can't perform at a higher level of baseballand are stuck at their current one.
- **Preprocessing changes:** You may swap `step_downsample()` with `step_smote()` from
  the themis package, or experiment with both if you think it will improve performance.
- **New variables:** Propose and create new features derived from existing columns in
  the dataset.
- **Fielding data (new):** The dataset now includes innings played at each position at
  each level, along with the player's putouts and assists at each position at each level.
  Prioritize exploring these variables early, both on their own and in interaction with existing
  power-shape and progression features. Make sure you pay attention to the defensive spectrum,
  i.e. the difference in raw putouts and assists figures for first basemen as opposed to outfielders
  and as opposed to shortstops, catchers, etc., since it may be a moderating variable on offensive
  thresholds for MLB success. You may use the given fielding variables to calculate more complex ones,
  such as range factor, outs above average, and/or defensive runs saved, if you are able.
- **Removing variables:** You may remove original features from the recipe if you have a clear 
  theoretical justification for why they are irrelevant or noisy, or if a 
  transformed or engineered version of that variable already exists in the 
  recipe, making the raw version redundant. Document which features you removed 
  and why in your run description.
- **External data sources:** If you believe a specific external variable, such as
  draft position or age at debut, would meaningfully help the objective, please
  flag it, along with where to find the data on it if possible, in your summary
  rather than attempting to load it directly.
  
Before exploring new directions, first revisit the following that were abandoned early in the 
previous loop:
- `step_smote()` in combination with the current best feature set
- Low-A to High-A delta features for ISO, HR/FB rate, and other lower minors features that you
  see fit
- Log transformations to ISO, HR, and fb_percent

Here are your hard constraints:

- Never remove `step_rm(x_mlbamid, name)` from the recipe.
- Never use any post-MLB debut data as a feature, since it will cause label leakage.
- `penalty` may be re-tuned if the feature space changes substantially, but keep `mixture = 1`
  at all times.
- Do not modify the outcome variable `success`.
- Always expose exactly two functions: `build_recipe(train_data)` and `build_model_spec()`.

To run an experiment after modifying `model.R`, run:

```r
Rscript run.R "brief description of what changed"
```

Check the j_index printed to the console and logged in `results.csv`.

Stop iterating if the j_index has not improved by at least 0.001 over the best
observed j_index in the past 10 consecutive iterations. Also stop if you reach 75
total iterations.

When stopping, provide a final report that includes:
- The best j_index achieved and which iteration produced it.
- Which changes helped and which didn't, referencing `results.csv`.
- The final state of `model.R` that produced the best result.
- Any external data sources you recommend exploring in a subsequent loop.