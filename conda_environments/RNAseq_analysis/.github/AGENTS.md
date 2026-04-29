# RNAseq Conda Environment — Agent Instructions

## Project purpose
Manages two conda environments for RNA-seq analysis (bulk, single-cell, spatial):
- `RNAseq_R` — R 4.5.x + Bioconductor/CRAN packages + upstream CLI tools (`fastqc`, `salmon`, `multiqc`, `picard`)
- `RNAseq_Python` — Python 3.13.x + scanpy/scvi ecosystem

See [README](../README) for a full description.

## Build commands
```bash
make            # full workflow: create-env → fix-cxx-standard → update-packages → install-packages → check-logs
make create-env
make update-packages
make install-packages
make check-logs
make clean
make help
```

> The Makefile targets `RNAseq_R` / `RNAseq_Python` (split from the original single `RNAseq` env).  
> Update the `ENV_NAME` references in [Makefile](../Makefile) and [xInstallPackages.sh](../xInstallPackages.sh) when changing which env is being built.

## Environment split — why two YAMLs
`r-base 4.5.x` and `python 3.13.x` share an unresolvable `libffi` conflict:
- R path needs `libffi >=3.5.2` (via `libglib >=2.86.4`)
- Python 3.13 needs `libffi <3.5.0`

Keep R and Python dependencies in separate environments. Do **not** attempt to merge them back into a single YAML.

| File | Env name | Contents |
|---|---|---|
| [RNAseq_R.yaml](../RNAseq_R.yaml) | `RNAseq_R` | r-base, CRAN, CLI tools, quarto |
| [RNAseq_Python.yaml](../RNAseq_Python.yaml) | `RNAseq_Python` | python, scanpy ecosystem, quarto |

## R package installation strategy (three-tier)

1. **conda/mamba** (YAML) — CRAN packages where a conda-forge build exists. Ensures system-level dependencies are met.
2. **`update-packages` target** — Runs [xUpdateRPackages.R](../xUpdateRPackages.R) inside the env to bring CRAN packages to their latest versions (conda builds lag behind CRAN).
3. **`install-packages` target** — Runs [xInstallPackages.sh](../xInstallPackages.sh), which iterates [PackagesToInstall.txt](../PackagesToInstall.txt) and calls [xrInstallPackage.R](../xrInstallPackage.R) for each:
   - Bioconductor packages → `BiocManager::install()`
   - GitHub packages → `pak::pak()` with `remotes::install_github()` fallback
   - All packages built **from source** (`pkgType = "source"`) to avoid glibc mismatches

## Key conventions
- **Source builds only**: `options(pkgType = "source")` is set in `xrInstallPackage.R`. Do not change this — binary Linux packages may require a newer glibc than the host.
- **C++ standard fix**: The `fix-cxx-standard` target appends `CXX11STD = -std=gnu++14` to the env's `R Makeconf`. This is required by `RcppArmadillo`. Run it once after `create-env`.
- **Log pattern**: Each package installation writes to `AllPackageInstallationLogs/<nn>_PackageInstallation_<pkg>.log`. Success/failure lines are prefixed `%% <pkg>: success|FAILURE|already installed`. The `check-logs` target greps for `FAILURE`.
- **Adding a new R package**: Add conda-forge entry to [RNAseq_R.yaml](../RNAseq_R.yaml) if available; otherwise add the package name (or `owner/repo` for GitHub) to [PackagesToInstall.txt](../PackagesToInstall.txt).
- **Adding a new Python package**: Add to [RNAseq_Python.yaml](../RNAseq_Python.yaml). Prefer conda-forge over pip; use `pip:` section only when no conda build exists.
