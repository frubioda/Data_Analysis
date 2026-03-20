# Cobalt Deposit Prospectivity (Contact-Based Between Rock Types Model)

A spatial model to estimate the **cobalt deposit likelihood** based on proximity to geological contacts between two types of rocks.

We will focus on ultramafic rocks (including serpentinite rocks) and granodiorite rocks to estimate the likelihood in the whole area, creating a probability heatmap.
---

## Approach

* Extract **contacts** by intersecting polygon boundaries of the two rock types
* Convert contacts into **sampled points**
* Use **`cKDTree`** for fast nearest-neighbor distance computation
* Apply a **quadratic decay function**:

  * Likelihood = **1 at contact**
  * Likelihood → **0 at 10 km (fall-off distance)**
* Generate a **grid-based heatmap** of likelihood values

**ultramafic rocks (proxy for serpentinite)** and **granodiorite**.

---

## ⚠️ Limitations

* **Single-factor model**
  Only considers contact proximity (ignores structure, alteration, geochemistry)

* **Simplified lithology**
  Treats all ultramafic rocks as serpentinite

* **Generic decay function**
  Not calibrated to real cobalt occurrences

---

## ▶️ Usage

### Install dependencies

```bash
pip install geopandas shapely scipy matplotlib pytest
```

### Run notebook

```bash
jupyter notebook
```

Open `notebook.ipynb` to:

* Load data (`BedrockP.gpkg`)
* Generate heatmap
* Visualize results

### Run tests

```bash
python3 -m pytest test_functions_kdtree.py
```

---

## 📁 Structure

```
.
├── functions_kdtree.py      # core model functions
├── test_functions_kdtree.py # unit tests
├── notebook.ipynb           # example workflow
├── BedrockP.gpkg            # input data
└── README.md
```

---

## 🚀 Next Steps

* **Multi-layer prospectivity modeling**
  Incorporate additional predictors:

  * Faults / structural lineaments
  * Geophysical data (magnetic, gravity)
  * Geochemical anomalies

* **Model calibration & validation**

  * Use known cobalt occurrences to tune decay parameters
  * Compare different distance functions (exponential, Gaussian)
  * Add cross-validation / ROC analysis

* **Advanced spatial methods**

  * Replace distance-only model with **machine learning** (e.g. Random Forest, XGBoost)
  * Use raster-based workflows for scalability (e.g. `rasterio`, `xarray`)

* **Performance optimization**

  * Parallelize grid computation
  * Reduce sampling density adaptively
  * Benchmark `cKDTree` vs other spatial indexing methods

* **Improved geological handling**

  * Better lithology classification (true serpentinite vs ultramafic subtypes)
  * Weight contacts by geological importance
  * Handle near-miss contacts more robustly

---

## ✅ Output

* 2D heatmap of cobalt likelihood
* Values range from **0 (low)** to **1 (high near contacts)**

---
