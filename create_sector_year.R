library(tidyverse)

students_sector_year <- tribble(
  ~sector, ~year, ~enrolments,
  "Higher Education", 2019, 440869,
  "Higher Education", 2020, 418365,
  "Higher Education", 2021, 365647,
  "Higher Education", 2022, 359926,
  "Higher Education", 2023, 434656,
  "Higher Education", 2024, 497187,
  "Higher Education", 2025, 545259,

  "VET", 2019, 281386,
  "VET", 2020, 304389,
  "VET", 2021, 281695,
  "VET", 2022, 270969,
  "VET", 2023, 324841,
  "VET", 2024, 391556,
  "VET", 2025, 363542,

  "Schools", 2019, 25459,
  "Schools", 2020, 20070,
  "Schools", 2021, 13018,
  "Schools", 2022, 11713,
  "Schools", 2023, 15827,
  "Schools", 2024, 19624,
  "Schools", 2025, 20344,

  "ELICOS", 2019, 156459,
  "ELICOS", 2020, 104722,
  "ELICOS", 2021, 41841,
  "ELICOS", 2022, 79357,
  "ELICOS", 2023, 161396,
  "ELICOS", 2024, 144206,
  "ELICOS", 2025, 93219,

  "Non-award", 2019, 48219,
  "Non-award", 2020, 32328,
  "Non-award", 2021, 13589,
  "Non-award", 2022, 20109,
  "Non-award", 2023, 32246,
  "Non-award", 2024, 36039,
  "Non-award", 2025, 35676
)

write_csv(students_sector_year, "data/students_sector_year.csv")

students_sector_year