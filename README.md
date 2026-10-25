# ECO346 Assignment 1: Earnings in Punjab (urban)

**Name:** Maryam Akram  **Reg. no.:** FA24-BEDS-089  **Section:** A

## Variant
Last two digits = 89. 89 = 11 x 8 + 1, so the remainder is **1 = Punjab urban** (`prov_code` 2, `urban_rural` 2).
Sample: persons aged 15-64 with `earn_annual` > 0 (earners). All statistics weighted by `hhweight`.

## How to reproduce
From the repository root, with no internet needed:

    Rscript scripts/01_default.R
    Rscript scripts/02_distribution.R
    Rscript scripts/03_relationship.R
    python scripts/04_second_language.py

## Figures
- Default: `figures/default.svg`
- Distribution (Q2): `figures/distribution.svg`
- Relationship (Q3, the redesign): `figures/relationship.svg`
- Python version (Q5): `figures/relationship_python.svg`

## Band table (weighted mean annual earnings)
| Band | Earners | Weighted mean (Rs) |
|---|---|---|
| 15-19 | 229 | 145,444 |
| 20-24 | 449 | 216,585 |
| 25-29 | 499 | 320,776 |
| 30-34 | 518 | 369,580 |
| 35-39 | 498 | 354,031 |
| 40-44 | 435 | 498,966 |
| 45-49 | 427 | 465,073 |
| 50-54 | 363 | 521,949 |
| 55-59 | 220 | 523,751 |
| 60-64 | 130 | 453,067 |

No band has fewer than 30 earners, so no marker is hollow.

## Interpretation

### Question 2: the distribution
- Earners: 3,768
- Median: weighted Rs 240,000, unweighted Rs 240,000
- Weighted 10th percentile: Rs 96,000; 90th percentile: Rs 660,000; ratio 6.88
- Excluded (outside Rs 10,000 to Rs 10,000,000): 25

Most earners make between about Rs 100,000 and Rs 400,000 a year. A long tail of high earners stretches to the right, so the top tenth earn 6.88 times the bottom tenth. The weighted and unweighted medians are both Rs 240,000. Many people report exactly Rs 240,000 (Rs 20,000 a month), and the weights differ only moderately across households, so both medians land on the same spike.

### Question 3: the relationship
- Weighted mean, ages 25-29: Rs 320,776
- Weighted mean, ages 45-49: Rs 465,073
- Highest weighted mean band: 55-59 (Rs 523,751)

Average earnings rise steeply from the late teens to the early 30s, dip slightly at 35-39, then reach about Rs 520,000 at ages 50-59 before falling at 60-64. This fits the human capital story: experience and skills raise pay. The highest band is 55-59, but 50-54 is almost equal, so the peak is flat. It cannot tell us how one person's pay grows over a lifetime, because it compares different people at one point in time.

### Question 4: the makeover
1. Log scale. The default squeezes almost every point near zero because a few earners make millions. A log scale spreads them out and shows percentage differences.
2. Jitter and transparency (alpha 0.15). Ages are whole numbers, so dots stack in vertical lines. Jitter and alpha reduce overplotting; dark patches show where many people sit.
3. Weighted band means joined by a line. A conditional mean shows the trend that a cloud of dots cannot, and position along a common axis is the most accurate channel.
4. Rupee labels, a finding as title, a caption, and no grey background (data-ink).
The default shows the extreme earners, such as the Rs 24 million earner. My redesign cuts off the 25 earners outside Rs 10,000 to Rs 10,000,000.

### Question 5: a second language (Python)
- 25-29 band mean from R: Rs 320,776; from Python: Rs 320,776

Both R and Python give Rs 320,776 for ages 25-29. One default that differed: random numbers for the jitter. R's set.seed(346) and NumPy's generator with seed 346 give different jitter, so the dots are not identical. I fixed both seeds and set the same alpha, axis limits (Rs 10,000 to Rs 10,000,000) and integer-division bands, so the band means match to the rupee.
