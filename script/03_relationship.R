# Question 3: earnings against age, with weighted band means (the redesign).
# Also writes the band table used in the README and in Question 5.
# Run from the repository root:  Rscript scripts/03_relationship.R
if (!file.exists("data/pslm_person_subset.csv")) stop("Run from the repository root (the folder that contains data/)")
library(tidyverse)
library(svglite)

person <- read_csv("data/pslm_person_subset.csv", show_col_types = FALSE)
hh     <- read_csv("data/pslm_hh_subset.csv",     show_col_types = FALSE)
d <- person %>%
  left_join(dplyr::select(hh, hhid, hhweight, prov_code, urban_rural), by = "hhid")
earners <- d %>%
  filter(prov_code == 2, urban_rural == 2,
         age >= 15, age <= 64, earn_annual > 0)

# Five-year bands by integer division (so age 20 is in 20-24, not 15-19)
earners <- earners %>%
  mutate(band_start = (age %/% 5) * 5)

bands <- earners %>%
  group_by(band_start) %>%
  summarise(n = n(),
            wmean = sum(hhweight * earn_annual) / sum(hhweight),
            .groups = "drop") %>%
  mutate(band = paste0(band_start, "-", band_start + 4),
         mid = band_start + 2,
         wmean = round(wmean),
         thin = n < 30)

print(as.data.frame(bands))
top <- bands[which.max(bands$wmean), ]
cat("Highest weighted mean band:", top$band, "Rs", top$wmean, "\n")
dir.create("tables", showWarnings = FALSE)
write_csv(dplyr::select(bands, band, n, wmean), "tables/band_table_R.csv")

rs <- function(v) paste0("Rs ", format(round(v), big.mark = ",", trim = TRUE))
set.seed(346)   # jitter is random; fixed seed makes the figure repeatable

g <- ggplot(earners, aes(age, earn_annual)) +
  geom_jitter(width = 0.4, height = 0, alpha = 0.15, size = 0.8,
              colour = "grey30") +
  geom_line(data = bands, aes(mid, wmean), colour = "#c0392b") +
  geom_point(data = bands, aes(mid, wmean, shape = thin),
             colour = "#c0392b", size = 3.5, stroke = 1.2) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 1), guide = "none") +
  annotate("text", x = top$mid, y = top$wmean * 2.2, colour = "#c0392b",
           label = paste0("Highest: ages ", top$band, "\n", rs(top$wmean))) +
  scale_y_log10(breaks = 10^(4:7),
                labels = c("Rs 10,000", "Rs 100,000",
                           "Rs 1,000,000", "Rs 10,000,000")) +
  coord_cartesian(ylim = c(1e4, 1e7)) +
  scale_x_continuous(breaks = seq(15, 65, by = 10)) +
  labs(title = paste0("Average earnings of Punjab's urban workers rise with age, peaking at ages ",
                      top$band),
       x = "Age (years)", y = "Annual earnings (log scale)",
       caption = paste0("Source: PSLM 2019-20. Sample: earners aged 15-64, Punjab urban (n = ",
                        nrow(earners), "). Weighted by hhweight (band means only). ",
                        "Red markers = weighted mean of each 5-year band; hollow markers = fewer than 30 observations. ",
                        "Points outside the axis range are not shown.")) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 11),
        panel.grid.minor = element_blank())

dir.create("figures", showWarnings = FALSE)
ggsave("figures/relationship.svg", g, width = 8, height = 5.5)
