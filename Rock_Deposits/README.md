# Cobalt Deposit Prospectivity (Contact-Based Between Rock Types Model)

A spatial model to estimate the **cobalt deposit likelihood** based on proximity to geological contacts between two types of rocks.

We focus on **ultramafic rocks** (including serpentinite rocks) and **granodiorite rocks** to estimate the likelihood in the whole area, creating a probability heatmap.

## Input Data

The model uses a geological dataset stored in a GeoPackage (gpkg format), containing the geometry type: Polygon (geological units), the coordinate system: Projected CRS (units in meters, required for distance calculations), and rock_type describing the lithology, among other parameters.

## Approach

We estimate the distance between the polygon boundaries of two rock types. At the intersection the probability of getting cobalt deposit is 1. We apply a smooth function to decrease the probability with the distance, such that at a inputed fall-off distance the likelihood of getting cobalt deposit is 0.

* Extract **contacts** by intersecting polygon boundaries of the two rock types
* Convert contacts into **sampled points**
* Use **`cKDTree`** for fast nearest-neighbor distance computation
* Apply a **quadratic decay function**:
  * Likelihood = **1 at contact**
  * Likelihood → **0 at 10 km (fall-off distance)**
* * Generate a **grid-based heatmap** of likelihood values focusing on **ultramafic rocks (proxy for serpentinite)** and **granodiorite**.

## Usage

### Install dependencies

```bash
pip install geopandas shapely scipy matplotlib pytest
```

### Run notebook

```bash
jupyter notebook
```

Open `cobalt_likelihood_kdtree.ipynb` to:

* Load data
* Generate heatmap
* Visualize results

### Run tests

```bash
python3 -m pytest test_functions_kdtree.py
```

## Structure

```
.
├── functions_kdtree.py              # core model functions
├── test_functions_kdtree.py         # unit tests
├── cobalt_likelihood_kdtree.ipynb   # example workflow
├── input_file.gpkg                  # input data
└── README.md
```

## Output

* Likelihood of cobalt occurring at a specific point based on the proximity of any two sets of rock types, with an adjustable fall-off distance parameter
* 2D heatmap of cobalt likelihood
* Values range from **0 (low)** to **1 (high near contacts)**

## Next Steps

* **Multi-layer prospectivity modeling**
  Incorporate additional predictors:

  * Faults / structural lineaments
  * Geophysical data (magnetic, gravity)
  * Geochemical anomalies

* **Model calibration & validation**

  * Use known cobalt occurrences to tune decay parameters
  * Compare different distance functions (exponential, Gaussian)
  * Add cross-validation / ROC analysis pending we have some true values to train the algorithm.

* **Advanced spatial methods**

  * Replace distance-only model with **machine learning** (e.g. Random Forest, XGBoost) pending we have some true values to train the algorithm.

* **Performance optimization**

  * Parallelize grid computation
  * Reduce sampling density adaptively
  * Benchmark `cKDTree` vs other spatial indexing methods

* **Improved geological handling**

  * Better lithology classification (true serpentinite vs ultramafic subtypes)
  * Weight contacts by geological importance
  * Handle near-miss contacts more robustly

## AI Usage & Transparency

AI tools were used to support development, debugging, and documentation of this project.

### Tools used

* **ChatGPT (OpenAI)**

### How AI was used

* Assisted in designing the **overall approach** (contact-based prospectivity model). I initially tried a K-Nearest Neighbors approach, but OpenAI showed me that with cKDTree I obtain the almost identical results in a faster way.
* Helped refine **Python functions** (e.g. contact extraction, sampling, cKDTree workflow)
* Supported **debugging**, particularly with geometry edge cases (e.g. `GeometryCollection`, `MultiPoint`)
* Generated initial versions of **unit tests** and **README documentation**

### Validation & refinement

* All AI-generated code was **reviewed and modified manually**
* Functions were tested using **synthetic geometries** and **pytest unit tests**
* Outputs (heatmaps and likelihood values) were visually inspected and checked for **logical consistency** (e.g. highest likelihood near contacts, decay with distance)
