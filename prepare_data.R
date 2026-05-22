library(tidyverse)
library(readxl)

show_top_rows <- function(path, sheet, n = 25) {
  raw <- read_excel(
    path,
    sheet = sheet,
    col_names = FALSE,
    n_max = n
  )
  
  print(raw[, 1:min(12, ncol(raw))], n = n, width = Inf)
}

show_top_rows(
  "data_raw/december_2025_all_data.xlsx",
  "AEI_Pivot",
  30
)

show_top_rows(
  "data_raw/december_2025_latest_data.xlsx",
  "AEI_Pivot",
  30
)

show_top_rows(
  "data_raw/International_students_studying_in_Australia_2005-2025.xlsx",
  "Sheet1",
  30
)

show_top_rows(
  "data_raw/abs_migration_visa_state.xlsx",
  "Table 4.1",
  35
)

dir.create("data", showWarnings = FALSE)

# Read the December 2025 latest pivot table
latest_raw <- read_excel(
  "data_raw/december_2025_latest_data.xlsx",
  sheet = "AEI_Pivot",
  col_names = FALSE
)

# Extract the sector table
sector_wide <- latest_raw %>%
  slice(16:22) %>%
  select(1:15)

# Manually name the columns based on the pivot structure
names(sector_wide) <- c(
  "sector",
  "enrolments_2019",
  "enrolments_2020",
  "enrolments_2021",
  "enrolments_2022",
  "enrolments_2023",
  "enrolments_2024",
  "enrolments_2025",
  "commencements_2019",
  "commencements_2020",
  "commencements_2021",
  "commencements_2022",
  "commencements_2023",
  "commencements_2024",
  "commencements_2025"
)

# Remove Grand Total and convert values to numeric
sector_wide <- sector_wide %>%
  filter(sector != "Grand Total") %>%
  mutate(across(-sector, as.numeric))

# Long version for time-series or stacked area chart
students_sector_year <- sector_wide %>%
  pivot_longer(
    cols = -sector,
    names_to = c("measure", "year"),
    names_pattern = "(.*)_(\\d{4})",
    values_to = "value"
  ) %>%
  mutate(year = as.integer(year))

write_csv(students_sector_year, "data/students_sector_year.csv")

# 2025 sector summary only
students_sector_2025 <- sector_wide %>%
  select(
    sector,
    enrolments = enrolments_2025,
    commencements = commencements_2025
  ) %>%
  arrange(desc(enrolments))

write_csv(students_sector_2025, "data/students_sector_2025.csv")

print(students_sector_2025)
print(list.files("data"))

source("prepare_data.R")

# 3. Historical student cohort by source country, 2005–2025

students_country_cohort_2005_2025 <- read_excel(
  "data_raw/International_students_studying_in_Australia_2005-2025.xlsx",
  sheet = "Sheet1",
  skip = 11,
  col_names = c(
    "country",
    "cohort_2005_2024_not_studying_2025",
    "cohort_2025_studying",
    "total_2005_2025"
  )
) %>%
  filter(!is.na(country)) |
  mutate(
    cohort_2005_2024_not_studying_2025 = as.numeric(cohort_2005_2024_not_studying_2025),
    cohort_2025_studying = as.numeric(cohort_2025_studying),
    total_2005_2025 = as.numeric(total_2005_2025)
  ) |
  arrange(desc(total_2005_2025)) |
  slice_head(n = 30)

write_csv(
  students_country_cohort_2005_2025,
  "data/students_country_cohort_2005_2025.csv"
)

print(students_country_cohort_2005_2025)
print(list.files("data"))
