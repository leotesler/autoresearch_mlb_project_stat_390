# Pull Pro Debut and Amateur Source Data

# load libraries ----
library(tidyverse)
library(here)
library(rvest)
library(httr)
library(httr2)
library(jsonlite)

# load data ----
load(here("clean_data/mlb_full.rds"))

# get IDs list ----
ids <- mlb_full |> 
  distinct(x_mlbamid) |> 
  pull(x_mlbamid)

# get birth country data ----
get_birth_country <- function(mlbamid) {
  url <- paste0("https://statsapi.mlb.com/api/v1/people/", mlbamid)
  response <- request(url) |> 
    req_perform() |> 
    resp_body_json()
  person <- response$people[[1]]
  tibble(
    x_mlbamid = mlbamid,
    birth_country = person$birthCountry,
    draft_year = person$draftYear
  )
}

birth_country <- map_dfr(ids, get_birth_country)

# get amateur source ----
draft_years <- birth_country |> 
  filter(!is.na(draft_year)) |> 
  distinct(draft_year) |> 
  pull(draft_year)

get_draft_info <- function(year) {
  url <- paste0("https://statsapi.mlb.com/api/v1/draft/", year)
  response <- request(url) |> 
    req_perform() |> 
    resp_body_json()
  
  picks <- response$drafts$rounds |> 
    map("picks") |> 
    list_flatten()
  
  map_dfr(picks, function(pick) {
    tibble(
      x_mlbamid = pick$person$id %||% NA_integer_,
      draft_type = pick$school$schoolClass %||% NA_character_
    )
  })
}

draft_data <- map_dfr(draft_years, \(year) {
  get_draft_info(year) |> mutate(draft_year = year)
}) |> 
  filter(x_mlbamid %in% ids) |> 
  distinct(x_mlbamid, .keep_all = TRUE)

draft_data |> 
  distinct(draft_type) |> 
  pull(draft_type)

# recode draft type ----
college_codes <- c("JR", "SO", "SR", "4YR JR", "4YR SO", "4YR SR", "4YR 5S", "4YR GR", "5S")
juco_codes <- c("J1", "J2", "J3", "JC J3", "JC J2", "JC J1")
hs_codes <- c("HS", "HS JR", "HS SR")

amateur_type <- draft_data |> 
  mutate(amateur_type = case_when(
    draft_type %in% college_codes ~ "college",
    draft_type %in% juco_codes ~ "juco",
    draft_type %in% hs_codes ~ "high_school",
    draft_type == "NS" ~ "no_school",
    is.na(draft_type) ~ "unknown"
  )) |> 
  select(x_mlbamid, amateur_type)

# join datasets ----
mlb_full <- mlb_full |> 
  left_join(amateur_type, by = "x_mlbamid") |> 
  left_join(birth_country |> 
              select(!draft_year),
            by = "x_mlbamid") |> 
  mutate(amateur_type = replace_when(
    amateur_type,
    is.na(amateur_type) & birth_country %in% c("USA", "Canada", "Puerto Rico") ~ "unknown",
    is.na(amateur_type) & !(birth_country %in% c("USA", "Canada", "Puerto Rico")) ~ "international"
  )) |> 
  select(!birth_country) |> 
  colnames()

# save data ----
save(mlb_full, file = "clean_data/mlb_full.rds")
