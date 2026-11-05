# NINJAX 5k GW+KN Dataset

This repository contains a preliminary population of 5,000 binary neutron star injections generated with [NINJAX](https://github.com/nuclear-multimessenger-astronomy/ninjax).

## Downloading the dataset

The generated `signals.h5` file is not stored directly in the repository. It is provided as a GitHub Release asset.

To download it with the GitHub CLI:

```bash
gh release download v0.1 \
    -R Xiaofei-D/GWKN_source_5k \
    -p signals.h5
```

## Files

- `signals.h5` — generated GW polarisations, KN light curves, and event parameters. Available from the GitHub Release.
- `signals.h5.sha256` — SHA-256 checksum for verifying the downloaded dataset.
- `generate_dataset.sh` — script for reproducing the dataset.
- `examples/read_hdf5.py` — example script for reading `signals.h5`.
- `data/prior.toml` — prior used to sample the binary population.
- `data/fixed_params.json` — parameters fixed for all events.
- `data/eos/ALF2.dat` — ALF2 EOS table used to calculate the tidal and ejecta quantities.


## Generation setup

* Number of events: `5,000`
* Random seed: `42`
* EOS: `ALF2`
* KN model: Fiesta `Bu2026_MLP`
* EM filters: `ztfg`, `ztfr`, `ztfi`
* EM error budget: None
* Output format: HDF5
* Batch size: `5,000`
* Cosmology: `Planck18`

### Sampled parameters

The binary population was sampled from `data/prior.toml`:

```toml
[prior]

mass_1              = { type = "uniform", min = 1.2, max = 1.6 } # Detector frame
mass_2              = { type = "uniform", min = 1.0, max = 1.2 } # Detector frame

luminosity_distance = { type = "power_law", min = 50.0, max = 200.0, alpha = 2.0 }

ra                   = { type = "uniform", min = 0.0, max = 6.283185307179586 }
dec                  = { type = "cosine" }
psi                  = { type = "uniform", min = 0.0, max = 3.141592653589793 }
theta_jn             = { type = "sine" }
phase                = { type = "uniform", min = 0.0, max = 6.283185307179586 }

geocent_time         = { type = "uniform", min = 1187008882.0, max = 1187008883.0 }

chi_1                = { type = "uniform", min = -0.05, max = 0.05 }
chi_2                = { type = "uniform", min = -0.05, max = 0.05 }
```

### Fixed parameters

The following parameters are fixed for all events, see `data/fixed_params.json`.

```python
{
    "v_ej_dyn": 0.2,
    "Ye_dyn": 0.15,
    "v_ej_wind": 0.1,
    "Ye_wind": 0.3,
    "luminosity_distance": 100 # Mpc
}
```

Note that `luminosity_distance` is overwritten by the fixed value above during data generation. All events therefore have `luminosity_distance = 100 Mpc`. NINJAX derives the corresponding `redshift` using the Planck18 cosmology (`z ≈ 0.0222`) and converts detector-frame masses to source frame before the EOS and ejecta calculations.

## GW data

The dataset contains zero-noise frequency-domain GW polarisations; detector strain is not included.

The shared frequency grid contains:

```text
4016 frequency samples
20.0 - 1023.75 Hz
delta_f = 0.25 Hz
```

The relevant HDF5 datasets are:

```text
gw/frequencies    (4016,)         float64
gw/p              (5000, 4016)    complex128
gw/c              (5000, 4016)    complex128
```

`gw/p` and `gw/c` contain the plus and cross polarisations, respectively.

The GW generation uses the same `luminosity_distance = 100 Mpc`.

## KN light curves

Each filter contains 87 time samples on a common grid in the observer frame spanning `0.1983627 - 28.1386188 days`:

```text
em/ztfg/time    (5000, 87)   float64
em/ztfg/mag     (5000, 87)   float64

em/ztfr/time    (5000, 87)   float64
em/ztfr/mag     (5000, 87)   float64

em/ztfi/time    (5000, 87)   float64
em/ztfi/mag     (5000, 87)   float64
```

Since no EM error budget was requested, no `mag_err` are included.

The stored values are apparent AB magnitudes at `luminosity_distance = 100 Mpc` with `redshift = 0.0222`.

## Event parameters

Per-event parameters are stored under:

```text
parameters/
```

Every dataset has shape `(5000,)`. This includes both sampled and fixed binary parameters and quantities derived internally by NINJAX, including:

```text
mass_1
mass_2
mass_1_source
mass_2_source
redshift
luminosity_distance
chi_1
chi_2
theta_jn
inclination_EM
lambda_1
lambda_2
radius_1
radius_2
compactness_1
compactness_2
log10_mej_dyn
log10_mej_wind
log10_mej
log10_mdisk
```

## Known non-finite EM subset

For 1,080 of the 5,000 events (`~22%`), the dynamical ejecta fitting formula returns zero mass, giving

```text
log10_mej_dyn = -inf
```

These events produce non-finite Fiesta KN light curves in all three filters, which are retained as `NaN` values.

## Final HDF5 file

The final file size is roughly `665 MB`. An example HDF5 reader is available at `examples/read_hdf5.py`.

## Reproducing the dataset

> **Note:** Generation is on GPU. Before running, ensure access to a CUDA-capable GPU.

NINJAX will refuse to overwrite an existing `signals.h5`, so move or delete it first.

Activate an environment with NINJAX installed, then run from the parent directory of this folder:

```bash
chmod +x GWKN_source_5k/generate_dataset.sh
./GWKN_source_5k/generate_dataset.sh
```

When installing NINJAX into a non-uv environment (e.g. conda), install it with `uv` rather than `pip` so that the pinned `jesterTOV` version is used:

```bash
cd ninjax
UV_PROJECT_ENVIRONMENT=$CONDA_PREFIX uv sync --frozen --extra cuda13 --inexact
```