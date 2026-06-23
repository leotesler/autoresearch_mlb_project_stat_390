# Evaluate Models with Prospect Rankings

# load libraries ----
library(tidyverse)
library(tidymodels)
library(here)
library(rvest)
library(httr)
library(jsonlite)
library(chromote)
library(baseballr)

# load data ----
load(here("clean_data/mlb_full.rds"))

# load models ----
load(here("final_models/models/lasso_model.rda"))
load(here("final_models/models/bt_model.rda"))

# pull prospect rankings ----
team_names <- c(
  "yankees", "redsox", "bluejays", "orioles", "rays",
  "whitesox", "guardians", "tigers", "twins", "royals",
  "angels", "athletics", "mariners", "rangers", "astros",
  "mets", "braves", "phillies", "marlins", "nationals",
  "reds", "cubs", "cardinals", "pirates", "brewers",
  "dodgers", "dbacks", "giants", "padres", "rockies"
)

top_30_rankings <- list()

for (team in team_names) {
  b <- ChromoteSession$new()
  b$Page$navigate(paste0("https://mlb.com/milb/prospects/", team))
  b$Page$loadEventFired()
  Sys.sleep(2)
  
  click_js <- "
    (() => {
      const btns = Array.from(document.querySelectorAll('button'));
      const target = btns.find(b => b.textContent.toLowerCase().includes('show full list'));
      if (target) { target.click(); return true; }
      return false;
    })()
  "
  
  clicked <- b$Runtime$evaluate(click_js)$result$value
  
  Sys.sleep(2)
  
  id_js <- "
    (() => {
      const rows = Array.from(document.querySelectorAll('table tbody tr'));
      return rows.map(row => {
        const a = row.querySelector('a[href*=\"/stories/\"]');
        if (!a) return null;
        const match = a.href.match(/-(\\d+)$/);
        return match ? match[1] : null;
      });
    })()
  "
  
  player_ids <- b$Runtime$evaluate(id_js, returnByValue = TRUE)$result$value
  
  n_rows <- b$Runtime$evaluate(
    "document.querySelectorAll('table tbody tr').length"
  )$result$value
  
  html <- b$Runtime$evaluate("document.documentElement.outerHTML")$result$value
  
  prospects <- read_html(html) |> 
    html_nodes("table") |> 
    html_table() |> 
    pluck(1)
  
  prospects$player_id <- unlist(player_ids)
  
  top_30_rankings[[team]] <- prospects
  
  b$close()
}

top_prospects <- bind_rows(top_30_rankings) |> 
  janitor::clean_names()

# clean and join ----
hitter_prospect_stats <- top_prospects |> 
  filter(!str_detect(pos, "^RHP|^LHP")) |> 
  select(player_id) |> 
  mutate(player_id = as.numeric(player_id)) |> 
  left_join(mlb_full, by = join_by(player_id == x_mlbamid)) |> 
  rename(x_mlbamid = player_id) |> 
  select(!starts_with("team")) |> 
  select(!starts_with("player_name")) |> 
  select(!starts_with("season")) |> 
  select(!starts_with("aff_id")) |> 
  select(!starts_with("aff_abb")) |> 
  select(!starts_with("a_level")) |> 
  select(!starts_with("level_")) |> 
  select(!starts_with("playerids")) |> 
  select(!starts_with("minormaster")) |> 
  select(!starts_with("player_team_id")) |> 
  select(!starts_with("position_db")) |> 
  select(!starts_with("max_age")) |> 
  separate(age_aaa, into = c("min_age_aaa", "max_age_aaa"), sep = "-") |> 
  separate(age_aa, into = c("min_age_aa", "max_age_aa"), sep = "-") |> 
  separate(age_ha, into = c("min_age_ha", "max_age_ha"), sep = "-") |> 
  separate(age_la, into = c("min_age_la", "max_age_la"), sep = "-") |> 
  separate(age_r, into = c("min_age_r", "max_age_r"), sep = "-") |> 
  select(!starts_with("max_age")) |> 
  mutate(across(starts_with("min_age"), ~as.numeric(.x)),
         debut_age = pmin(min_age_r, min_age_la, min_age_ha, min_age_aa, min_age_aaa))

# predict ----
hitter_prospect_stats |> 
  bind_cols(predict(lasso_model, hitter_prospect_stats, type = "prob")) |> 
  select(name, .pred_Yes) |> 
  arrange(desc(.pred_Yes)) |> 
  print(n = 30)
