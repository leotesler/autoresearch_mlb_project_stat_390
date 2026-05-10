# Pull MiLB Data from Fangraphs

# load libraries ----
library(tidyverse)
library(httr)
library(rvest)
library(jsonlite)
library(here)

# define season list, function ----
seasons <- as.character(2010:2025)
seasons <- seasons[-11]

milb_fielding <- function(year, sportId, limit = 1000, offset = 0) {
  results <- list()
  
  repeat {
    url <- paste0(
      "https://statsapi.mlb.com/api/v1/stats?stats=season&group=fielding&gameType=R&season=",
      year, "&sportId=", sportId, "&playerPool=ALL&limit=", limit, "&offset=", offset
    )
    
    splits <- fromJSON(
      content(
        GET(url),
        as = "text",
        encoding = "UTF-8"
      ),
      flatten = TRUE
    )$stats$splits[[1]]
    
    if (is.null(splits) || nrow(splits) == 0) break
    results <- c(results, list(splits))
    
    if (nrow(splits) < limit) break
    offset <- offset + limit
  }
  
  bind_rows(results) |> 
    tibble() |> 
    janitor::clean_names()
}

# load raw data ----
aaa_data <- map_dfr(seasons, milb_fielding, sportId = 11)
aa_data <- map_dfr(seasons, milb_fielding, sportId = 12)
ha_data <- map_dfr(seasons, milb_fielding, sportId = 13)
la_data <- map_dfr(seasons, milb_fielding, sportId = 14)
r_data <- map_dfr(seasons, milb_fielding, sportId = 16)

# bind and clean data ----
raw_field <- bind_rows(
  aaa_data, aa_data, ha_data, la_data, r_data
) |> 
  filter(!(position_abbreviation %in% c("P", "DH"))) |> 
  mutate(across(stat_fielding:stat_innings, as.numeric),
         sport_abbreviation = if_else(
           sport_abbreviation %in% c("A(Full)", "A(Adv)"), "A+", sport_abbreviation
         ))

clean_field <- raw_field |> 
  select(player_id, player_full_name, season, level = sport_abbreviation, 
         position = position_abbreviation, inn = stat_innings, 
         putouts = stat_put_outs, assists = stat_assists) |> 
  mutate(inn = if_else(near(inn %% 1, 0.1), floor(inn) + 1/3, inn),
         inn = if_else(near(inn %% 1, 0.2), floor(inn) + 2/3, inn)) |> 
  pivot_wider(names_from = position, values_from = c("inn", "putouts", "assists")) |> 
  unnest(inn_2B:last_col()) |> 
  mutate(across(everything(), ~replace_na(.x, 0)),
         level = factor(level),
         level = fct_recode(
           level,
           "aaa" = "AAA",
           "aa" = "AA",
           "ha" = "A+",
           "la" = "A",
           "r" = "ROK"
         )) |> 
  group_by(player_id, level) |> 
  summarize(
    across(inn_2B:last_col(), ~sum(.x))
  ) |> 
  ungroup() |> 
  pivot_wider(names_from = level, values_from = inn_2B:last_col()) |> 
  janitor::clean_names() |> 
  mutate(across(everything(), ~replace_na(.x, 0)))

# load mlb_full and join ----
load(here("clean_data/mlb_full.rds"))

mlb_full <- mlb_full |> 
  left_join(clean_field, by = join_by(x_mlbamid == player_id))

# save data ----
save(mlb_full, file = "clean_data/mlb_full.rds")
