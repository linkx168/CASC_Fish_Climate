library(halk)
library(arrow)
library(data.table)
library(tidyverse)

age_structures <- c("most_common_structure")

halk_aged_by_spp_path <- "data/parquet_files/wi_data/halk_aged_data_by_spp/"

combine_aged_files <- lapply(age_structures, function(x) {
  halk_aged_files <- paste0(
    halk_aged_by_spp_path, 
    dir(halk_aged_by_spp_path), "/",
    paste0(x, "s"),
    "/part-0.parquet"
  )
  halk_aged_files <- halk_aged_files[file.exists(halk_aged_files)]
  
  halk_aged_datasets <- open_dataset(here::here(halk_aged_files))
  write_dataset(
    halk_aged_datasets, 
    path = here::here(sprintf(
      "data/parquet_files/wi_data/halk_aged_data/%ss",
      x
    ))
  )
})
