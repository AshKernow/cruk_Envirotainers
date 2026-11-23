# Shared R environment build scripts

The R conda environments in `ATAC/`, `DNAseq/`, `proteomics/` and
`RNAseq_analysis/` are built with the scripts and Makefile recipes in this
folder. Each environment folder only contains its YAML files, package list(s)
and a thin `Makefile`. Make changes to the build logic here so every
environment picks them up.

Why: for R 4.6 there are no bioconda/conda-forge builds of most R packages yet,
so the conda env provides R plus the compiler toolchain and system libraries,
and the R packages are then installed/updated from source with BiocManager
inside the env.

## Files

1. `R_env.mk`: Makefile fragment with shared settings and canned recipes.
1. `xInstallPackages.sh`: installs each package in a package list (one log per
   package) and writes a summary log. Configured by environment variables
   `ENV_NAME` (required), `PKG_LIST`, `LOG_DIR`, `SUMMARY_LOG`.
1. `xrInstallPackage.R`: installs one CRAN/Bioconductor package with
   BiocManager, or a GitHub package (`owner/repo`) with pak, falling back to
   remotes. It prints `%% <pkg>: success|FAILURE|already installed`.
1. `xUpdateRPackages.R`: updates all installed packages and logs what changed.

## Using it from an environment Makefile

```make
include ../R_build_common/R_env.mk

R_ENV := MyEnv_R

create-env:
	$(call create_conda_env,$(R_ENV),$(R_ENV).yaml)
install-packages:
	$(call install_r_pkgs,$(R_ENV),PackagesToInstall.txt,$(R_LOG_DIR),$(R_SUMMARY_LOG))
```

`R_env.mk` defines no targets, so the including Makefile's first target stays
the default.

| Macro | Arguments | What it does |
|---|---|---|
| `create_conda_env` | env, yaml | Create the env, or update it (`--prune`) if it exists |
| `fix_cxx_standard` | env | Set `CXX11STD = -std=gnu++14` in R's `Makeconf` (newer RcppArmadillo) |
| `bootstrap_r_pkgs` | env | Install BiocManager/remotes/pak if missing |
| `update_r_pkgs` | env, log file | Run `xUpdateRPackages.R` |
| `install_r_pkgs` | env, package list, log dir, summary log | Run `xInstallPackages.sh`; skip if the list is missing or empty |
| `check_r_logs` | log dir, summary log | Fail on any `FAILURE`, otherwise delete the logs |
| `clean_r_logs` | log dir, summary log | Delete the logs |

Variables (override on the command line, e.g. `make update-packages CRAN_MIRROR=...`):
`CRAN_MIRROR` (default `https://cloud.r-project.org`), `R_LOG_DIR`
(`AllPackageInstallationLogs`), `R_SUMMARY_LOG`
(`AllPackageInstallationSummary.log`), `R_UPDATE_LOG`
(`$(R_LOG_DIR)/00_RPackageUpdate.log`). On macOS, `create_conda_env` sets
`CONDA_SUBDIR=osx-64`.

Logs and package lists are relative to the environment folder that `make` is
run from.

## Package list format

One package per line; lines starting with `#` are ignored. CRAN and
Bioconductor packages are given by name, GitHub packages as `owner/repo`
(or `owner/repo/subdir`).
