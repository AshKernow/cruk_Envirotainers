# Shared Makefile fragment for building R conda environments.
#
# Include from an environment folder's Makefile (before any targets):
#
#     include ../R_build_common/R_env.mk
#
# It defines no targets, only shared settings and canned recipes. Use them
# inside a target's recipe with $(call <macro>,<args>), e.g.
#
#     create-env:
#     	$(call create_conda_env,ATACseq_R,ATACseq_R.yaml)
#
# Paths for package lists and logs are relative to the including Makefile's
# folder; the shared scripts are found via $(R_COMMON_DIR).

# Must be evaluated before any other include changes MAKEFILE_LIST
R_COMMON_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SHELL := /bin/bash
.SHELLFLAGS := -lc

CRAN_MIRROR ?= https://cloud.r-project.org

# Default log locations (override per environment as needed)
R_LOG_DIR ?= AllPackageInstallationLogs
R_SUMMARY_LOG ?= AllPackageInstallationSummary.log
R_UPDATE_LOG ?= $(R_LOG_DIR)/00_RPackageUpdate.log

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    CONDA_SUBDIR_PREFIX := CONDA_SUBDIR=osx-64
    SED_INPLACE := sed -i ''
else
    CONDA_SUBDIR_PREFIX :=
    SED_INPLACE := sed -i
endif

# ---------------------------------------------------------------------------
# create_conda_env: create, or update if it exists, a conda environment
#   $(1) environment name
#   $(2) environment YAML file
# ---------------------------------------------------------------------------
define create_conda_env
@echo "Creating conda environment '$(1)'..."
@if conda env list | grep -q "^$(1) "; then \
	echo "Environment '$(1)' already exists. Updating..."; \
	$(CONDA_SUBDIR_PREFIX) mamba env update -n $(1) -f $(2) --prune; \
else \
	$(CONDA_SUBDIR_PREFIX) mamba env create -y -f $(2); \
fi
@echo "Conda environment '$(1)' ready."
endef

# ---------------------------------------------------------------------------
# fix_cxx_standard: make R use C++14 when compiling packages that declare
# C++11 (required by newer RcppArmadillo)
#   $(1) environment name
# ---------------------------------------------------------------------------
define fix_cxx_standard
@MAKECONF=$$(conda run -n $(1) Rscript -e "cat(file.path(R.home('etc'), 'Makeconf'))"); \
if grep -q "^CXX11STD *= *-std=gnu++14" "$$MAKECONF"; then \
	echo "CXX11STD already set to -std=gnu++14 in $$MAKECONF — skipping."; \
elif grep -q "^CXX11STD" "$$MAKECONF"; then \
	echo "WARNING: CXX11STD found in $$MAKECONF but not set to gnu++14 — overwriting."; \
	$(SED_INPLACE) 's|^CXX11STD.*|CXX11STD = -std=gnu++14|' "$$MAKECONF"; \
	echo "WARNING: Done — CXX11STD updated to -std=gnu++14 in $$MAKECONF"; \
else \
	echo "WARNING: Appending 'CXX11STD = -std=gnu++14' to $$MAKECONF"; \
	echo "WARNING: This overrides the C++11 standard flag to C++14, required by RcppArmadillo."; \
	echo "CXX11STD = -std=gnu++14" >> "$$MAKECONF"; \
	echo "WARNING: Done — CXX11STD written to $$MAKECONF"; \
fi
endef

# ---------------------------------------------------------------------------
# bootstrap_r_pkgs: install BiocManager/remotes/pak if missing (there are no
# R 4.6 conda builds of them yet)
#   $(1) environment name
# ---------------------------------------------------------------------------
define bootstrap_r_pkgs
@echo "Bootstrapping BiocManager/remotes/pak in '$(1)'..."
@conda run -n $(1) Rscript -e 'options(repos = c(CRAN = "$(CRAN_MIRROR)")); for (p in c("BiocManager", "remotes", "pak")) if (!requireNamespace(p, quietly = TRUE)) install.packages(p)'
endef

# ---------------------------------------------------------------------------
# update_r_pkgs: update all installed R packages and write an update log
#   $(1) environment name
#   $(2) update log file
# ---------------------------------------------------------------------------
define update_r_pkgs
@echo "Updating installed R packages in '$(1)'..."
@mkdir -p $(dir $(2))
@conda run -n $(1) Rscript $(R_COMMON_DIR)/xUpdateRPackages.R "$(CRAN_MIRROR)" "$(2)"
@echo "R package update complete. Log: $(2)"
endef

# ---------------------------------------------------------------------------
# install_r_pkgs: install the CRAN/Bioconductor/GitHub packages in a list,
# skipping if the list is missing or empty
#   $(1) environment name
#   $(2) package list file
#   $(3) per-package log directory
#   $(4) summary log file
# ---------------------------------------------------------------------------
define install_r_pkgs
@if [[ ! -f $(2) ]]; then \
	echo "$(2) not found. Skipping R package installation."; \
elif grep -Eq '^[[:space:]]*[^#[:space:]]' $(2); then \
	echo "Installing R packages from $(2) into '$(1)'..."; \
	ENV_NAME=$(1) PKG_LIST=$(2) LOG_DIR=$(3) SUMMARY_LOG=$(4) $(R_COMMON_DIR)/xInstallPackages.sh; \
else \
	echo "No R packages listed in $(2). Skipping."; \
fi
endef

# ---------------------------------------------------------------------------
# check_r_logs: fail if the summary log reports any FAILURE, otherwise clean
# up the logs
#   $(1) per-package log directory
#   $(2) summary log file
# ---------------------------------------------------------------------------
define check_r_logs
@echo "Checking installation logs for failures..."
@if [[ ! -f $(2) ]]; then \
	echo "No installation summary log found. Skipping log check."; \
elif grep -q "FAILURE" $(2); then \
	echo ""; \
	echo "❌ INSTALLATION FAILURES DETECTED"; \
	echo "Check $(2) for details."; \
	echo ""; \
	exit 1; \
else \
	echo ""; \
	echo "✅ All packages installed successfully!"; \
	echo "Cleaning up log files..."; \
	rm -rf $(1) $(2); \
	echo "Done."; \
	echo ""; \
fi
endef

# ---------------------------------------------------------------------------
# clean_r_logs: remove the logs
#   $(1) per-package log directory
#   $(2) summary log file
# ---------------------------------------------------------------------------
define clean_r_logs
@echo "Removing log files..."
@rm -rf $(1) $(2)
@echo "Logs removed."
endef
