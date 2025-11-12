library(halk)
library(arrow)
library(data.table)
library(tidyverse)
library(StreamCatTools)

#install data from Paul's package
load("mwcascfish_src/mwcascfish/data/lake_huc10.rda")
load("mwcascfish_src/mwcascfish/data/ecoregions.rda")


age_structures <- c("most_common_structure")
spp_list <- c(
  "black_crappie", "bluegill", "cisco", "largemouth_bass", "northern_pike",
  "smallmouth_bass", "walleye", "yellow_perch"
)

ia_data <- open_dataset(sources = file.path("G:", 
                                            "Shared drives", 
                                            "Hansen Lab", 
                                            "RESEARCH PROJECTS", 
                                            "Fish Survey Data", 
                                            "Parquet files", 
                                            "hive_update", 
                                            "state=Iowa",
                                            "part-0.parquet")) %>% 
  select(-est_age,
         -alk,
         -alk_age_str,
         -alk_length,
         -alk_n)

tictoc::tic()
ia_halk_aged_data <- lapply(spp_list, function(x) {
    formatted_data <- 
      ia_data |> 
      rename_with(~gsub("_1$", "", .x)) |>
      rename_with(~gsub("_", ".", .x)) |>
      mutate(
        year = year,
        lake.id = as.character(lake.id),
        length.unit = case_when(
          !is.na(length.unit) ~ "in",
          !is.na(length.bin) ~ "in",
          TRUE ~ as.character(NA)
        )
      ) |>  
      filter(species == x)
    nonlength_data <- 
      formatted_data |>
      filter(is.na(length) & is.na(length.bin)) |>
      collect() 
    length_data <- 
      formatted_data |> 
      filter(!(is.na(length) & is.na(length.bin))) |>
      collect() |>
      mutate(
        lower = as.numeric(sub("-.*", "", length.bin)),
        upper = floor(as.numeric(sub(".*-", "", length.bin))),
        lower = case_when(lower == 0 ~ 1,
                          TRUE ~ lower),
        length = case_when(
          is.na(length) & !is.na(length.bin) ~ 
            round(runif(n(), lower, upper)),
          TRUE ~ length
      )) %>% 
      select(-lower, -upper) %>% 
      mutate(length = case_when(
        length.unit == "mm" ~ length / 10,
        length.unit == "cm" ~ length,
        length.unit == "in" ~ length * 2.54
      )) |>
      left_join(
        lake_huc10 |>
          ungroup() |>
          mutate(lake.id = gsub("^0", "", lake.id)) |>
          left_join(
            data.frame(state = tolower(state.abb), state.name),
            by = "state"
          ) |> select(-state) |> rename(state = state.name),
        by = c("state", "lake.id")
      ) |>
      left_join(
        ecoregions |>
          mutate(lake.id = gsub("^0", "", lake.id)) |>
          left_join(
            data.frame(state = tolower(state.abb), state.name),
            by = "state"
          ) |> select(-state) |> rename(state = state.name),
        by = c("state", "lake.id")
      ) |>
      rename(huc10.code = huc.code) |>
      mutate(huc8.code = substr(huc10.code, 1, 8)) %>% 
      mutate(
        lake.id = replace_na(lake.id, "skip_lake"),
        year = replace_na(year, -9999),
        huc10.code = replace_na(huc10.code, "skip_huc10"),
        huc8.code = replace_na(huc8.code, "skip_huc8"),
        level3_ecoregion = replace_na(level3_ecoregion, "skip_ecoregion")) 
    halk_str_aged_data <- lapply(age_structures, function(y, spp = x) {
      load(here::here("midwest_most_common_structure_halk_2025-09-03.RData"))
      spp_halk <- filter(halk, species == spp)
      aged_data <- 
        assign_ages(length_data, spp_halk) |>
        # backtransform length to original based on length unit
        mutate(length = case_when(
          length.unit == "mm" ~ length * 10,
          length.unit == "cm" ~ length,
          length.unit == "in" ~ length / 2.54
        )) |>
        select(
          -matches("huc.*(code|name|level)"),
          -ends_with("_ecoregion")
        ) |>        
        bind_rows(nonlength_data)
      file_path <- paste0(
        "data/parquet_files/ia_data/halk_aged_data_by_spp/", 
        spp,
        "/", paste0(y, "s")
      )
      write_dataset(aged_data, here::here(file_path))
      rm(halk, aged_data)
      gc()
      return(NULL)
    })
    rm(length_data, nonlength_data, formatted_data)
    gc()
    return(NULL)
})
tictoc::toc()

