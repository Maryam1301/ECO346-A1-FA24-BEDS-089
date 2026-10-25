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

