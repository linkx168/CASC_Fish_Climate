# MidFish: A Large-Scale Aggregation of State Fisheries Data from the Midwestern United States

Denver Link, Michael R. Verhoeven, Holly K. Masui, Jenna K.R. Nelson, Paul N. Frater, and Gretchen J.A. Hansen

Data that accompany this code repository are found on ScienceBase: 
[INSERT CITATION]

This repository contains code used to produce a reproducible, statewide aggregation of fisheries survey data from the Midwestern United States, as well as scripts that use the cleaned and aggregated dataset to generate region-wide abundance products and age-based analyses. Files are indexed using prefixes a–e to indicate their role within the workflow. Files with prefixes a–b use original state agency data to produce state-level Parquet files through an extensive data aggregation process. These files collectively form a region-wide, hive-partitioned fisheries database. Files with prefixes c–e operate on this hived dataset rather than on raw state-level data. Specifically, c-prefixed files read the hived dataset to generate state-specific abundance products. The d-prefixed file contain analyses using the hived dataset that are referenced in a companion manuscript (Hansen et al, in prep). Lastly the e-prefixed file does a general exploration of the hived database.

Users should note that the original, raw fisheries survey data required to run a–b prefixed scripts are not made publicly avaiable. Users interested in exploring or modifying the aggregation workflow that converts raw state data into the cleaned hived dataset should contact the authors directly and/or request access to the original data from the relevant state agencies.

The aggregation scripts were developed using a combination of tidyverse and data.table, with the Arrow package used to write state-level Parquet files for improved memory efficiency and scalability. Scripts that operate on the hived dataset primarily use tidyverse in combination with Arrow. Users are encouraged to familiarize themselves with the interaction between Arrow and tidyverse when working with the hived data product. Extensive in-line comments and documentation are provided throughout the codebase to promote transparency and reproducibility. Users should update all file paths to reflect the locations where the data are stored on their own systems, as the file paths in these scripts reflect the development team’s local directory structure.

## Code Files

This repository includes the following scripts and workflows, organized by prefix to reflect their role in the data pipeline.

### a — Original data column naming and reading

- **a_CASC_Data_Explainer_Work_MRV.Rmd**  
  Documentation-focused script used to standardize and validate incoming state-level fisheries data prior to aggregation.

---

### b — State-level data aggregation

The following scripts aggregate raw state fisheries data into standardized, state-level Parquet files that collectively form the MidFish Hive dataset.

- **b_IA_Flat_File_Aggregation.Rmd** — Iowa data aggregation  
- **b_IL_Flat_File_Aggregation.Rmd** — Illinois data aggregation  
- **b_IN_Flat_File_Aggregation.Rmd** — Indiana data aggregation  
- **b_MI_Flat_File_Aggregation.Rmd** — Michigan data aggregation  
- **b_MN_Flat_File_Aggregation.Rmd** — Minnesota data aggregation  
- **b_SD_Flat_File_Aggregation.Rmd** — South Dakota data aggregation  
- **b_WI_Flat_File_Aggregation.Rmd** — Wisconsin data aggregation  

#### b_HALK — Hierarchical Age–Length Key (HALK) workflow

`b_HALK` is a multi-step workflow used to apply hierarchical age–length keys to estimate fish ages following Frater et al 2024. This folder contains three sub-workflows:

##### a_create_halk
- **create_mw_most_common_structure_halk.R**  
  Generates regional, species-specific hierarchical age–length keys using the most commonly sampled aging structure within each of the groups: species, ecoregion, huc8, huc10, lake, and lake-year.

##### b_state_halk_assignment
Applies the HALK models to state-specific datasets to assign ages probabilistically based on length.

- **halk_age_ia_spp_data.R**  
- **halk_age_il_spp_data.R**  
- **halk_age_in_spp_data.R**  
- **halk_age_mi_spp_data.R**  
- **halk_age_mn_spp_data.R**  
- **halk_age_sd_spp_data.R**  
- **halk_age_wi_spp_data.R**  

- **combine_halk_aged_ia_spp_data.R**  
- **combine_halk_aged_il_spp_data.R**  
- **combine_halk_aged_in_spp_data.R**  
- **combine_halk_aged_mi_spp_data.R**  
- **combine_halk_aged_mn_spp_data.R**  
- **combine_halk_aged_sd_spp_data.R**  
- **combine_halk_aged_wi_spp_data.R**  

##### c_create_crosswalk
- **product_combine.Rmd**  
  Combines HALK-aged and observed-age data into a unified dataset and generates crosswalks between original and HALK age estimates records. This crosswalk is used in the aggregation script to attach HALK ages. 

---

### c — CPUE and abundance products

These scripts operate on the hived dataset to generate state-level and regional abundance products.

- **c_IA_Filtering_for_CPUE.Rmd**  
- **c_IL_Filtering_for_CPUE.Rmd**  
- **c_IN_Filtering_for_CPUE.Rmd**  
- **c_MI_Filtering_for_CPUE.Rmd**  
- **c_MN_Filtering_for_CPUE.Rmd**  
- **c_SD_Filtering_for_CPUE.Rmd**  
- **c_WI_Filtering_for_CPUE.Rmd**  

- **c_filtered_state_combining.Rmd**  
  Combines state-level CPUE and abundance products into a single region-wide dataset.

---

### d — Analytical scripts

- **d_time_to_size.Rmd**  
  Analysis of time-to-size relationships using the hived dataset, referenced in the companion manuscript.

---

### e — User-facing exploration

- **e_data_exploration.Rmd**  
  Introductory and exploratory script designed to help users load, inspect, and work with the MidFish hived dataset.
