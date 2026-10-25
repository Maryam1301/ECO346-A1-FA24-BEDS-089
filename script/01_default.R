# Question 4 (first half): R's default scatterplot, nothing added.
# Run from the repository root:  Rscript scripts/01_default.R
if (!file.exists("data/pslm_person_subset.csv")) stop("Run from the repository root (the folder that contains data/)")
library(tidyverse)
library(svglite)

person <- read_csv("data/pslm_person_subset.csv", show_col_types = FALSE)
hh     <- read_csv("data/pslm_hh_subset.csv",     show_col_types = FALSE)

# Attach weight, province and area from the household file, by hhid
d <- person %>%
  left_join(dplyr::select(hh, hhid, hhweight, prov_code, urban_rural), by = "hhid")

# Variant 1 = Punjab (prov_code 2) urban (urban_rural 2); earners aged 15-64
earners <- d %>%
  filter(prov_code == 2, urban_rural == 2,
         age >= 15, age <= 64, earn_annual > 0)

dir.create("figures", showWarnings = FALSE)
p <- ggplot(earners, aes(age, earn_annual)) + geom_point()
ggsave("figures/default.svg", p, width = 7, height = 5)
