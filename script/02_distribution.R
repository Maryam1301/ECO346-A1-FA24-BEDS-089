# Question 2: weighted histogram of annual earnings on a log10 scale.
# Run from the repository root:  Rscript scripts/02_distribution.R
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

# Weighted quantile exactly as the assignment defines it:
# sort by x, cumulative share of weight, smallest x where share >= p.
wquantile <- function(x, w, p) {
  o <- order(x)
  x <- x[o]; w <- w[o]
  share <- cumsum(w) / sum(w)
  x[which(share >= p - 1e-12)[1]]     # tiny tolerance for floating point
}

x <- earners$earn_annual
w <- earners$hhweight

n_earners  <- nrow(earners)
med_w      <- wquantile(x, w, 0.5)
med_unw    <- median(x)
p10        <- wquantile(x, w, 0.1)
p90        <- wquantile(x, w, 0.9)
ratio      <- round(p90 / p10, 2)
inside     <- x >= 1e4 & x <= 1e7
n_excluded <- sum(!inside)

cat("Earners:", n_earners, "\n")
cat("Weighted median:", med_w, " Unweighted median:", med_unw, "\n")
cat("P10:", p10, " P90:", p90, " P90/P10:", sprintf("%.2f", ratio), "\n")
cat("Excluded (outside Rs 10,000 - Rs 10,000,000):", n_excluded, "\n")

# Histogram: bins 0.1 wide in log10 units, 4.0 to 7.0.
# Density per log10 unit = (weight in bin / total weight in range) / 0.1
h <- tibble(lx = log10(x[inside]), w = w[inside])
edges <- round(seq(4, 7, by = 0.1), 1)
h$bin <- cut(h$lx, breaks = edges, right = FALSE, include.lowest = TRUE)
bins <- h %>%
  group_by(bin) %>%
  summarise(wt = sum(w), .groups = "drop") %>%
  mutate(left = edges[-length(edges)][as.integer(bin)],
         density = wt / sum(wt) / 0.1)

rs <- function(v) paste0("Rs ", format(round(v), big.mark = ",", trim = TRUE))

g <- ggplot(bins, aes(x = left + 0.05, y = density)) +
  geom_col(width = 0.1, fill = "grey60", colour = "white") +
  geom_vline(xintercept = log10(c(med_w, p90)), linetype = "dashed") +
  annotate("text", x = log10(med_w) - 0.05, y = max(bins$density),
           label = paste("Median", rs(med_w)), hjust = 1) +
  annotate("text", x = log10(p90) + 0.05, y = max(bins$density) * 0.8,
           label = paste("90th percentile", rs(p90)), hjust = 0) +
  scale_x_continuous(breaks = 4:7,
                     labels = c("Rs 10,000", "Rs 100,000",
                                "Rs 1,000,000", "Rs 10,000,000")) +
  labs(title = paste0("Half of Punjab's urban earners make ", rs(med_w),
                      " a year or less; the top tenth make ", rs(p90), " or more"),
       x = "Annual earnings (log scale)",
       y = "Density per log10 unit",
       caption = paste0("Source: PSLM 2019-20. Sample: earners aged 15-64, Punjab urban (n = ",
                        n_earners, "). Weighted by hhweight. ",
                        n_excluded, " earners outside Rs 10,000-Rs 10,000,000 excluded.")) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold", size = 11),
        panel.grid.minor = element_blank())

dir.create("figures", showWarnings = FALSE)
ggsave("figures/distribution.svg", g, width = 8, height = 5)
