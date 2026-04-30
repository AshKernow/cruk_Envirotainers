.PHONY: all create-r create-env-r create-env-python create-env-tools fix-cxx-standard update-packages install-packages check-logs clean help

SHELL := /bin/bash
.SHELLFLAGS := -lc

CRAN_MIRROR ?= https://cloud.r-project.org
R_UPDATE_LOG ?= AllPackageInstallationLogs/00_RPackageUpdate.log

# Default target
all: create-env-r create-env-python create-env-tools fix-cxx-standard update-packages install-packages check-logs

# R-only build (skips Python and Tools environments)
create-r: create-env-r fix-cxx-standard update-packages install-packages check-logs

# Create/update R conda environment
create-env-r:
	@echo "Creating conda environment 'RNAseq_R'..."
	@if conda env list | grep -q "^RNAseq_R "; then \
		echo "Environment 'RNAseq_R' already exists. Updating..."; \
		mamba env update -f RNAseq_R.yaml --prune --yes; \
	else \
		mamba env create -f RNAseq_R.yaml --yes; \
	fi
	@echo "Conda environment 'RNAseq_R' ready."

# Create/update CLI tools conda environment
create-env-tools:
	@echo "Creating conda environment 'RNAseq_Tools'..."
	@if conda env list | grep -q "^RNAseq_Tools "; then \
		echo "Environment 'RNAseq_Tools' already exists. Updating..."; \
		mamba env update -f RNAseq_Tools.yaml --prune --yes; \
	else \
		mamba env create -f RNAseq_Tools.yaml --yes; \
	fi
	@echo "Conda environment 'RNAseq_Tools' ready."

# Create/update Python conda environment
create-env-python:
	@echo "Creating conda environment 'RNAseq_Python'..."
	@if conda env list | grep -q "^RNAseq_Python "; then \
		echo "Environment 'RNAseq_Python' already exists. Updating..."; \
		mamba env update -f RNAseq_Python.yaml --prune --yes; \
	else \
		mamba env create -f RNAseq_Python.yaml --yes; \
	fi
	@echo "Conda environment 'RNAseq_Python' ready."

# Ensure R uses C++14 when compiling packages that declare C++11 (required by newer RcppArmadillo)
fix-cxx-standard:
	@MAKECONF=$$(conda run -n RNAseq_R Rscript -e "cat(file.path(R.home('etc'), 'Makeconf'))"); \
	if grep -q "^CXX11STD" "$$MAKECONF"; then \
		echo "WARNING: CXX11STD already set in $$MAKECONF — skipping."; \
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
	@echo "  help             - Show this help message"
