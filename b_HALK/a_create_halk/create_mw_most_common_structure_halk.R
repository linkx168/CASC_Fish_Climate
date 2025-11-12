library(halk)
library(arrow)
library(data.table)
library(tidyverse)

str_to_use <- "most_common"

# get MN age data
mn_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=Minnesota",
                                            "part-0.parquet"))

mn_age_data <- 
  mn_data |> 
  select(
    state, county, lake_id, nhdhr_id, year, species_1, 
    length_1, length_unit_1, age, aging_structure_1
  ) |> 
  rename_with(
    \(x) gsub("\\_1$", "", x), 
    .cols = c("species_1", "length_1", "length_unit_1", "aging_structure_1")
  ) |>
  rename_with(\(x) gsub("_", ".", x)) |>
  filter(!is.na(age), !is.na(length)) |> 
  mutate(across(lake.id, as.character)) |>
  collect() |> 
  mutate(state = "mn") %>% 
  mutate(aging.structure = case_when(aging.structure == "Otolith" ~ "otolith",
                                     TRUE ~ aging.structure),
         nhdhr.id = gsub("nhdhr_", "", nhdhr.id))
rm(mn_data)

# get WI age data
wi_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=Wisconsin",
                                            "part-0.parquet"))

wi_age_data <- 
  wi_data |> 
  select(
    state, county, lake_id, nhdhr_id, year, species_1,
    length_1, age, aging_structure_1
  ) |> 
  rename(aging.structure = aging_structure_1) |>
  rename_with(~gsub("_", ".", .x)) |>
  mutate(across(lake.id, as.character)) |>
  filter(!is.na(age), !is.na(length.1)) |> 
  collect() |> 
  mutate(state = "wi", nhdhr.id = gsub("nhdhr_", "", nhdhr.id)) |>
  mutate(length.unit = "in") %>% 
  rename(species = species.1,
         length = length.1)
rm(wi_data)

# get MI age data
mi_data <- open_dataset(sources = file.path("G:", 
                                                    "Shared drives", 
                                                    "Hansen Lab", 
                                                    "RESEARCH PROJECTS", 
                                                    "Fish Survey Data", 
                                                    "Parquet files", 
                                                    "hive_update", 
                                                    "state=Michigan",
                                                    "part-0.parquet"))

mi_age_data <- mi_data %>% 
  filter(!is.na(age)) %>% 
  collect() %>% 
  select(
    state, county, nhdhr.id = nhdhr_id, lake.id = lake_id, year, species = species_1,
    length = length_1, age, aging.structure = aging_structure_1
  ) %>% 
  mutate(across(lake.id, as.character)) %>% 
  filter(!is.na(age), !is.na(length)) %>% 
  mutate(state = "mi",
         nhdhr.id = gsub("nhdhr_", "", nhdhr.id),
         length.unit = "in")
rm(mi_data)

# get SD age data
sd_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=South_Dakota",
                                            "part-0.parquet"))

sd_age_data <- 
  sd_data |> 
  select(
    state, county, lake_id, nhdhr_id, year, species_1, 
    length_1, length_unit_1, age, 
    aging_structure_1
  ) |> 
  rename_with(\(x) gsub("\\_1$", "", x)) |>
  rename_with(\(x) gsub("_", ".", x)) |>
  filter(!is.na(age), !is.na(length), !is.na(lake.id)) |> 
  mutate(across(lake.id, as.character)) |>
  collect() |> 
  mutate(state = "sd", length.unit = gsub("known_units_", "", length.unit),
         nhdhr.id = gsub("nhdhr_", "", nhdhr.id))
rm(sd_data)

# get IA age data
ia_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=Iowa",
                                            "part-0.parquet"))

ia_age_data <-
  ia_data |> 
  select(
    state, county, lake_id, nhdhr_id, year, 
    species_1, length_1, length_unit_1,
    age, aging_structure_1
  ) |>
  rename_with(\(x) gsub("\\_1$", "", x)) |>
  rename_with(\(x) gsub("_", ".", x)) |>
  filter(!is.na(age), !is.na(length), !is.na(lake.id)) |> 
  mutate(across(lake.id, as.character)) |>
  collect() |> 
  mutate(state = "ia") |>
  mutate(aging.structure = case_when(
    str_detect(aging.structure, "spine") ~ "spine",
    str_detect(aging.structure, "otolith") ~ "otolith",
    TRUE ~ aging.structure
  ),
  nhdhr.id = gsub("nhdhr_", "", nhdhr.id)) |>
  mutate(length.unit = "in")
rm(ia_data)

# get IL age data
il_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=Illinois",
                                            "part-0.parquet"))

il_age_data <-
  il_data |> 
  select(
    state, county, nhdhr_id, lake_id, year, 
    species_1, length_1, length_unit_1,
    age, aging_structure_1
  ) |>
  rename_with(\(x) gsub("\\_1$", "", x)) |>
  rename_with(\(x) gsub("_", ".", x)) |>
  filter(!is.na(age), !is.na(length), !is.na(lake.id)) |> 
  mutate(across(lake.id, as.character)) |>
  collect() |> 
  mutate(state = "il",
         nhdhr.id = gsub("nhdhr_", "", nhdhr.id))
rm(il_data)

# get IN age data
in_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=Indiana",
                                            "part-0.parquet"))

in_age_data <-
  in_data |> 
  select(
    state, county, lake_id, year,
    species_1, length_1, length_unit_1,
    age, aging_structure_1
  ) |>
  rename_with(\(x) gsub("\\_1$", "", x)) |>
  rename_with(\(x) gsub("_", ".", x)) |>
  filter(!is.na(age), !is.na(length), !is.na(lake.id)) |> 
  mutate(across(lake.id, as.character)) |>
  collect() |> 
  mutate(state = "in") |>
  mutate(length.unit = "in")
rm(in_data)

spp_list <- c(
  "walleye", "bluegill", "cisco", "northern_pike", "largemouth_bass",
  "yellow_perch", "black_crappie", "smallmouth_bass"
)


all_age_data <- 
  bind_rows(
    mn_age_data,
    wi_age_data,
    mi_age_data,
    sd_age_data,
    ia_age_data,
    il_age_data,
    in_age_data
  ) %>% 
  mutate(species = case_when(species == "cisco/lake_herring" ~ "cisco",
                             TRUE ~ species)) %>% 
  mutate(length.unit = case_when(length.unit == "millimeters" ~ "mm",
                                 TRUE ~ length.unit)) %>% 
  filter(species %in% spp_list) |>
  mutate(
    length = case_when(
      length.unit == "mm" ~ length / 10,
      length.unit == "cm" ~ length,
      length.unit == "in" ~ length * 2.54
    ), 
    length.unit = "cm"
  )


#directly read in landscape data
load("mwcascfish_src/mwcascfish/data/lake_huc10.rda")
load("mwcascfish_src/mwcascfish/data/ecoregions.rda")


halk_age_data <- 
  all_age_data |>
  filter(!(is.na(lake.id) | is.na(year))) |>
  filter(!is.na(aging.structure)) |>
  filter(length != 0) %>% 
  filter(age < 100) %>% 
  mutate(aging.structure = case_when(str_detect(aging.structure, "spine") ~ "spine",
                                     TRUE ~ aging.structure)) %>% 
  filter(aging.structure %in% c("spine", "otolith", "scale", "cleithrum", "fin_ray")) %>% 
  filter(length < 500) %>% 
  left_join(
    lake_huc10 |>
      ungroup() |>
      mutate(lake.id = gsub("^0", "", lake.id)),
    by = c("state", "lake.id")
  ) |>
  left_join(
    ecoregions |>
      mutate(lake.id = gsub("^0", "", lake.id)),
    by = c("state", "lake.id")
  ) |>
  select(
    state, county, lake.id, nhdhr.id, year, species, length, length.unit,
    age, aging.structure, huc.code, level3_ecoregion
  ) |>
  rename(huc10.code = huc.code) |>
  filter(!is.na(huc10.code), !is.na(level3_ecoregion)) |>
  mutate(huc8.code = substr(huc10.code, 1, 8))

halk_levels <- c(
  "species", "level3_ecoregion", "huc8.code", "huc10.code", "lake.id", "year"
)

  
halk <- make_halk(
  halk_age_data, 
  levels = halk_levels, 
  size_col = "length", 
  age_col = "age",
  age_str = "most_common", 
  age_str_col = "aging.structure"
)

today <- format(Sys.time(), "%Y-%m-%d")
save(
  halk, 
  file = here::here(sprintf(
    "midwest_most_common_structure_halk_%s.RData", today
  ))
)
