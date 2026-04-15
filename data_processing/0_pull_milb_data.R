# Pull MiLB Data from Fangraphs

# load libraries ----
library(tidyverse)
library(httr)
library(rvest)
library(jsonlite)
library(here)

# load AAA data ----
url_aaa <- "https://www.fangraphs.com/api/leaders/minor-league/data?pos=all&level=1&lg=2,4,5,6,7,8,9,10,11,14,12,13,15,16,17,18,30,32&stats=bat&qual=0&type=0&team=&season=2010&seasonEnd=2025&org=&ind=0&splitTeam=false&players=&sort=23,1"
response_aaa <- GET(url_aaa)
raw_aaa <- content(response_aaa, as = "text", encoding = "UTF-8")
json_aaa <- fromJSON(raw_aaa)
aaa_data <- json_aaa |> 
  tibble() |> 
  janitor::clean_names() |> 
  mutate(name = gsub('.*">(.+)</.*', "\\1", name)) |> 
  rename_with(~paste0(.x, "_aaa"), -c("x_mlbamid", "name"))

# load AA data ----
url_aa <- "https://www.fangraphs.com/api/leaders/minor-league/data?pos=all&level=2&lg=2,4,5,6,7,8,9,10,11,14,12,13,15,16,17,18,30,32&stats=bat&qual=0&type=0&team=&season=2010&seasonEnd=2025&org=&ind=0&splitTeam=false&players=&sort=23,1"
response_aa <- GET(url_aa)
raw_aa <- content(response_aa, as = "text", encoding = "UTF-8")
json_aa <- fromJSON(raw_aa)
aa_data <- json_aa |> 
  tibble() |> 
  janitor::clean_names() |> 
  mutate(name = gsub('.*">(.+)</.*', "\\1", name)) |> 
  rename_with(~paste0(.x, "_aa"), -c("x_mlbamid", "name"))

# load High A data ----
url_high_a <- "https://www.fangraphs.com/api/leaders/minor-league/data?pos=all&level=3&lg=2,4,5,6,7,8,9,10,11,14,12,13,15,16,17,18,30,32&stats=bat&qual=0&type=0&team=&season=2010&seasonEnd=2025&org=&ind=0&splitTeam=false&players=&sort=23,1"
response_high_a <- GET(url_high_a)
raw_high_a <- content(response_high_a, as = "text", encoding = "UTF-8")
json_high_a <- fromJSON(raw_high_a)
high_a_data <- json_high_a |> 
  tibble() |> 
  janitor::clean_names() |> 
  mutate(name = gsub('.*">(.+)</.*', "\\1", name)) |> 
  rename_with(~paste0(.x, "_ha"), -c("x_mlbamid", "name"))

# load Low A data ----
url_low_a <- "https://www.fangraphs.com/api/leaders/minor-league/data?pos=all&level=4,5&lg=2,4,5,6,7,8,9,10,11,14,12,13,15,16,17,18,30,32&stats=bat&qual=0&type=0&team=&season=2010&seasonEnd=2025&org=&ind=0&splitTeam=false&players=&sort=23,1"
response_low_a <- GET(url_low_a)
raw_low_a <- content(response_low_a, as = "text", encoding = "UTF-8")
json_low_a <- fromJSON(raw_low_a)
low_a_data <- json_low_a |> 
  tibble() |> 
  janitor::clean_names() |> 
  mutate(name = gsub('.*">(.+)</.*', "\\1", name)) |> 
  rename_with(~paste0(.x, "_la"), -c("x_mlbamid", "name"))

# load Rookie Ball data ----
url_rookie <- "https://www.fangraphs.com/api/leaders/minor-league/data?pos=all&level=6,7,8&lg=2,4,5,6,7,8,9,10,11,14,12,13,15,16,17,18,30,32&stats=bat&qual=0&type=0&team=&season=2010&seasonEnd=2025&org=&ind=0&splitTeam=false&players=&sort=23,1"
response_rookie <- GET(url_rookie)
raw_rookie <- content(response_rookie, as = "text", encoding = "UTF-8")
json_rookie <- fromJSON(raw_rookie)
rookie_data <- json_rookie |> 
  tibble() |> 
  janitor::clean_names() |> 
  mutate(name = gsub('.*">(.+)</.*', "\\1", name)) |> 
  rename_with(~paste0(.x, "_r"), -c("x_mlbamid", "name"))

# get names and ids ----
names <- bind_rows(
  aaa_data, aa_data, high_a_data, low_a_data, rookie_data
) |> 
  select(x_mlbamid, name) |> 
  distinct()

# join data ----
milb_full <- names |> 
  left_join(
    aaa_data,
    by = join_by(x_mlbamid, name)
  ) |> 
  left_join(
    aa_data,
    by = join_by(x_mlbamid, name)
  ) |> 
  left_join(
    high_a_data,
    by = join_by(x_mlbamid, name)
  ) |> 
  left_join(
    low_a_data,
    by = join_by(x_mlbamid, name)
  ) |> 
  left_join(
    rookie_data,
    by = join_by(x_mlbamid, name)
  )

# save data ----
dir.create("clean_data")

save(milb_full, file = "clean_data/milb_full.rds")
