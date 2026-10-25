"""Question 5: the Question 3 band table and figure, redone in Python.
Run from the repository root:  python scripts/04_second_language.py
"""
import os
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FixedFormatter, NullLocator

person = pd.read_csv("data/pslm_person_subset.csv")
hh = pd.read_csv("data/pslm_hh_subset.csv")
d = person.merge(hh[["hhid", "hhweight", "prov_code", "urban_rural"]],
                 on="hhid", how="left")

# Variant 1 = Punjab (2) urban (2); earners aged 15-64
e = d[(d.prov_code == 2) & (d.urban_rural == 2) &
      d.age.between(15, 64) & (d.earn_annual > 0)].copy()

# Five-year bands by integer division
e["band_start"] = (e.age // 5) * 5
rows = []
for start, g in e.groupby("band_start"):
    wmean = (g.hhweight * g.earn_annual).sum() / g.hhweight.sum()
    rows.append({"band": f"{start}-{start + 4}", "n": len(g),
                 "wmean": int(round(wmean)), "mid": start + 2})
bands = pd.DataFrame(rows)
print(bands[["band", "n", "wmean"]].to_string(index=False))
os.makedirs("tables", exist_ok=True)
os.makedirs("figures", exist_ok=True)
bands[["band", "n", "wmean"]].to_csv("tables/band_table_python.csv", index=False)

# Compare with the R table if it exists
if os.path.exists("tables/band_table_R.csv"):
    r = pd.read_csv("tables/band_table_R.csv")
    same = (r.wmean.values == bands.wmean.values).all()
    print("R and Python band means identical to the rupee:", same)

# Figure
rng = np.random.default_rng(346)
jit = e.age + rng.uniform(-0.4, 0.4, len(e))
top = bands.loc[bands.wmean.idxmax()]
fig, ax = plt.subplots(figsize=(8, 5.5))
ax.scatter(jit, e.earn_annual, s=5, alpha=0.15, color="0.3", linewidths=0)
ax.plot(bands.mid, bands.wmean, color="#c0392b", lw=1.5)
thin = bands.n < 30
ax.scatter(bands.mid[~thin], bands.wmean[~thin], s=45, color="#c0392b", zorder=3)
ax.scatter(bands.mid[thin], bands.wmean[thin], s=45, facecolors="none",
           edgecolors="#c0392b", linewidths=1.5, zorder=3)
ax.annotate(f"Highest: ages {top.band}\nRs {int(top.wmean):,}",
            (top.mid, top.wmean), (top.mid, top.wmean * 2.2),
            ha="center", color="#c0392b")
ax.set_yscale("log")
ax.set_ylim(1e4, 1e7)
ax.yaxis.set_major_locator(FixedLocator([1e4, 1e5, 1e6, 1e7]))
ax.yaxis.set_major_formatter(FixedFormatter(["Rs 10,000", "Rs 100,000", "Rs 1,000,000", "Rs 10,000,000"]))
ax.yaxis.set_minor_locator(NullLocator())
ax.set_xticks(range(15, 65, 10))
ax.set_xlabel("Age (years)")
ax.set_ylabel("Annual earnings (log scale)")
for s in ("top", "right"):
    ax.spines[s].set_visible(False)
ax.set_title(f"Average earnings of Punjab's urban workers rise with age, peaking at ages {top.band}",
             fontsize=10, fontweight="bold", loc="left")
fig.text(0.01, 0.01,
         f"Source: PSLM 2019-20. Sample: earners aged 15-64, Punjab urban (n = {len(e)}). Weighted by hhweight (band means only).\n"
         "Red markers = weighted mean of each 5-year band; hollow markers = fewer than 30 observations.",
         fontsize=7, ha="left", va="bottom")
fig.tight_layout(rect=(0, 0.07, 1, 1))
fig.savefig("figures/relationship_python.svg")
