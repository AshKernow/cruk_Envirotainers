.PHONY: all create-r create-env-r create-env-python create-env-tools fix-cxx-standard update-packages install-packages check-logs clean help \
        create-r4.6 create-env-r4.6 fix-cxx-standard-r4.6 bootstrap-r4.6 update-packages-r4.6 install-packages-r4.6 check-logs-r4.6 clean-r4.6

SHELL := /bin/bash
.SHELLFLAGS := -lc

CRAN_MIRROR ?= https://cloud.r-project.org
R_UPDATE_LOG ?= AllPackageInstallationLogs/00_RPackageUpdate.log

# R 4.6 build: a separate environment/yaml/package-list living alongside the
# existing RNAseq_R environment (which stays untouched for ongoing projects).
# None of the bioconductor-*/r-* conda packages have R 4.6 builds yet, so
# they're installed manually via BiocManager::install() (see
# PackagesToInstall_R4.6.txt) instead of via RNAseq_R4.6.yaml.
R46_ENV := RNAseq_R4.6
R46_YAML := RNAseq_R4.6.yaml
R46_PKGLIST := PackagesToInstall_R4.6.txt
R46_LOGDIR := AllPackageInstallationLogs_R4.6
R46_SUMMARY := AllPackageInstallationSummary_R4.6.log
R46_UPDATE_LOG ?= $(R46_LOGDIR)/00_RPackageUpdate.log

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    CONDA_SUBDIR_PREFIX := CONDA_SUBDIR=osx-64
    SED_INPLACE := sed -i ''
else
    CONDA_SUBDIR_PREFIX :=
    SED_INPLACE := sed -i
endif

# Default target
all: create-env-r create-env-python create-env-tools fix-cxx-standard update-packages install-packages check-logs

# R-only build (skips Python and Tools environments)
create-r: create-env-r fix-cxx-standard update-packages install-packages check-logs

# Create/update R conda environment
create-env-r:
	@echo "Creating conda environment 'RNAseq_R'..."
	@if conda env list | grep -q "^RNAseq_R "; then \
		echo "Environment 'RNAseq_R' already exists. Updating..."; \
		$(CONDA_SUBDIR_PREFIX) mamba env update -f RNAseq_R.yaml --prune; \
	else \
		$(CONDA_SUBDIR_PREFIX) mamba env create -f RNAseq_R.yaml --yes; \
	fi
	@echo "Conda environment 'RNAseq_R' ready."

# Create/update CLI tools conda environment
create-env-tools:
	@echo "Creating conda environment 'RNAseq_Tools'..."
	@if conda env list | grep -q "^RNAseq_Tools "; then \
		echo "Environment 'RNAseq_Tools' already exists. Updating..."; \
		$(CONDA_SUBDIR_PREFIX) mamba env update -f RNAseq_Tools.yaml --prune; \
	else \
		$(CONDA_SUBDIR_PREFIX) mamba env create -f RNAseq_Tools.yaml --yes; \
	fi
	@echo "Conda environment 'RNAseq_Tools' ready."

# Create/update Python conda environment
create-env-python:
	@echo "Creating conda environment 'RNAseq_Python'..."
	@if conda env list | grep -q "^RNAseq_Python "; then \
		echo "Environment 'RNAseq_Python' already exists. Updating..."; \
		$(CONDA_SUBDIR_PREFIX) mamba env update -f RNAseq_Python.yaml --prune; \
	else \
		$(CONDA_SUBDIR_PREFIX) mamba env create -f RNAseq_Python.yaml --yes; \
	fi
	@echo "Conda environment 'RNAseq_Python' ready."

# Ensure R uses C++14 when compiling packages that declare C++11 (required by newer RcppArmadillo)
fix-cxx-standard:
	@MAKECONF=$$(conda run -n RNAseq_R Rscript -e "cat(file.path(R.home('etc'), 'Makeconf'))"); \
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

# Update installed R packages in the conda environment
update-packages:
	@echo "Updating installed R packages in 'RNAseq_R'..."
	@mkdir -p AllPackageInstallationLogs
	@conda run -n RNAseq_R Rscript xUpdateRPackages.R "$(CRAN_MIRROR)" "$(R_UPDATE_LOG)"
	@echo "R package update complete. Log: $(R_UPDATE_LOG)"

# Install GitHub R packages
install-packages:
	@echo "Installing GitHub R packages..."
	@./xInstallPackages.sh

# Check logs for failures and clean up if successful
check-logs:
	@echo "Checking installation logs for failures..."
	@if grep -q "FAILURE" AllPackageInstallationSummary.log; then \
		echo ""; \
		echo "❌ INSTALLATION FAILURES DETECTED"; \
		echo "Check AllPackageInstallationSummary.log for details."; \
		echo ""; \
		exit 1; \
	else \
		echo ""; \
		echo "✅ All packages installed successfully!"; \
		echo "Cleaning up log files..."; \
		rm -rf AllPackageInstallationLogs AllPackageInstallationSummary.log; \
		echo "Done."; \
		echo ""; \
	fi

# Clean up log files (manual cleanup)
clean:
	@echo "Removing log files..."
	@rm -rf AllPackageInstallationLogs AllPackageInstallationSummary.log
	@echo "Logs removed."

# --- R 4.6 build (separate environment, does not touch RNAseq_R) ---

# R-only build for the R 4.6 environment
create-r4.6: create-env-r4.6 fix-cxx-standard-r4.6 bootstrap-r4.6 install-packages-r4.6 update-packages-r4.6 check-logs-r4.6

# Create/update the RNAseq_R4.6 conda environment
create-env-r4.6:
	@echo "Creating conda environment '$(R46_ENV)'..."
	@if conda env list | grep -q "^$(R46_ENV) "; then \
		echo "Environment '$(R46_ENV)' already exists. Updating..."; \
		$(CONDA_SUBDIR_PREFIX) mamba env update -n $(R46_ENV) -f $(R46_YAML) --prune; \
	else \
		$(CONDA_SUBDIR_PREFIX) mamba env create -f $(R46_YAML) --yes; \
	fi
	@echo "Conda environment '$(R46_ENV)' ready."

# Ensure R uses C++14 when compiling packages that declare C++11 (required by newer RcppArmadillo)
fix-cxx-standard-r4.6:
	@MAKECONF=$$(conda run -n $(R46_ENV) Rscript -e "cat(file.path(R.home('etc'), 'Makeconf'))"); \
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

# Bootstrap BiocManager/pak/remotes, since r-biocmanager/r-pak have no R 4.6
# conda builds yet either and so aren't in RNAseq_R4.6.yaml
bootstrap-r4.6:
	@echo "Bootstrapping BiocManager/remotes/pak in '$(R46_ENV)'..."
	@conda run -n $(R46_ENV) Rscript -e 'options(repos = c(CRAN = "$(CRAN_MIRROR)")); for (p in c("BiocManager", "remotes", "pak")) if (!requireNamespace(p, quietly = TRUE)) install.packages(p)'

# Install CRAN/Bioconductor/GitHub R packages not yet built for R 4.6 in conda
install-packages-r4.6:
	@echo "Installing R packages into '$(R46_ENV)'..."
	@ENV_NAME=$(R46_ENV) PKG_LIST=$(R46_PKGLIST) LOG_DIR=$(R46_LOGDIR) SUMMARY_LOG=$(R46_SUMMARY) ./xInstallPackages.sh

# Update installed R packages in the RNAseq_R4.6 conda environment
update-packages-r4.6:
	@echo "Updating installed R packages in '$(R46_ENV)'..."
	@mkdir -p $(R46_LOGDIR)
	@conda run -n $(R46_ENV) Rscript xUpdateRPackages.R "$(CRAN_MIRROR)" "$(R46_UPDATE_LOG)"
	@echo "R package update complete. Log: $(R46_UPDATE_LOG)"

# Check R 4.6 build logs for failures and clean up if successful
check-logs-r4.6:
	@echo "Checking installation logs for failures..."
	@if grep -q "FAILURE" $(R46_SUMMARY); then \
		echo ""; \
		echo "❌ INSTALLATION FAILURES DETECTED"; \
		echo "Check $(R46_SUMMARY) for details."; \
		echo ""; \
		exit 1; \
	else \
		echo ""; \
		echo "✅ All packages installed successfully!"; \
		echo "Cleaning up log files..."; \
		rm -rf $(R46_LOGDIR) $(R46_SUMMARY); \
		echo "Done."; \
		echo ""; \
	fi

# Clean up R 4.6 build log files (manual cleanup)
clean-r4.6:
	@echo "Removing R 4.6 build log files..."
	@rm -rf $(R46_LOGDIR) $(R46_SUMMARY)
	@echo "Logs removed."

# Help target
help:
	@echo "Available targets:"
	@echo "  all               - Create/update all environments, update R packages, install GitHub packages (default)"
	@echo "  create-r          - R-only build: create RNAseq_R, fix C++ standard, update and install R packages"
	@echo "  create-env-r      - Create/update the RNAseq_R conda environment"
	@echo "  create-env-python - Create/update the RNAseq_Python conda environment"
	@echo "  create-env-tools  - Create/update the RNAseq_Tools conda environment (fastqc, salmon, multiqc, picard)"
	@echo "  update-packages  - Update installed R packages in RNAseq_R and write update log"
	@echo "  install-packages - Install GitHub-only R packages (PackagesToInstall.txt)"
	@echo "  fix-cxx-standard - Set CXX11STD=C++14 in RNAseq_R's R Makeconf (fixes RcppArmadillo build)"
	@echo "  check-logs       - Check logs for failures and clean up if successful"
	@echo "  clean            - Remove log files"
	@echo "  create-r4.6          - R 4.6 build: create RNAseq_R4.6 (separate env), install/update R packages"
	@echo "  create-env-r4.6      - Create/update the RNAseq_R4.6 conda environment"
	@echo "  bootstrap-r4.6       - Install BiocManager/remotes/pak into RNAseq_R4.6 (no R 4.6 conda builds yet)"
	@echo "  install-packages-r4.6 - Install CRAN/Bioconductor/GitHub R packages into RNAseq_R4.6 (PackagesToInstall_R4.6.txt)"
	@echo "  update-packages-r4.6 - Update installed R packages in RNAseq_R4.6 and write update log"
	@echo "  fix-cxx-standard-r4.6 - Set CXX11STD=C++14 in RNAseq_R4.6's R Makeconf"
	@echo "  check-logs-r4.6      - Check RNAseq_R4.6 logs for failures and clean up if successful"
	@echo "  clean-r4.6           - Remove RNAseq_R4.6 log files"
	@echo "  help             - Show this help message"
