.PHONY: all create-env fix-cxx-standard bootstrap-packages update-packages install-packages check-logs clean help

SHELL := /bin/bash
.SHELLFLAGS := -lc

CRAN_MIRROR ?= https://cloud.r-project.org
R_UPDATE_LOG ?= AllPackageInstallationLogs/00_RPackageUpdate.log

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    CONDA_SUBDIR_PREFIX := CONDA_SUBDIR=osx-64
    SED_INPLACE := sed -i ''
else
    CONDA_SUBDIR_PREFIX :=
    SED_INPLACE := sed -i
endif

# Default target
all: create-env fix-cxx-standard bootstrap-packages install-packages update-packages check-logs

# Create/update proteomics conda environment
create-env:
	@echo "Creating conda environment 'proteomics'..."
	@if conda env list | grep -q "^proteomics "; then \
		echo "Environment 'proteomics' already exists. Updating..."; \
		$(CONDA_SUBDIR_PREFIX) mamba env update -f proteomics.yaml --prune; \
	else \
		$(CONDA_SUBDIR_PREFIX) mamba env create -f proteomics.yaml --yes; \
	fi
	@echo "Conda environment 'proteomics' ready."

# Ensure R uses C++14 when compiling packages that declare C++11 (required by newer RcppArmadillo)
fix-cxx-standard:
	@MAKECONF=$$(conda run -n proteomics Rscript -e "cat(file.path(R.home('etc'), 'Makeconf'))"); \
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

# Bootstrap BiocManager/remotes/pak, since there are no R 4.6 conda builds of
# them yet and so they aren't in proteomics.yaml
bootstrap-packages:
	@echo "Bootstrapping BiocManager/remotes/pak in 'proteomics'..."
	@conda run -n proteomics Rscript -e 'options(repos = c(CRAN = "$(CRAN_MIRROR)")); for (p in c("BiocManager", "remotes", "pak")) if (!requireNamespace(p, quietly = TRUE)) install.packages(p)'

# Update installed R packages in the conda environment
update-packages:
	@echo "Updating installed R packages in 'proteomics'..."
	@mkdir -p AllPackageInstallationLogs
	@conda run -n proteomics Rscript xUpdateRPackages.R "$(CRAN_MIRROR)" "$(R_UPDATE_LOG)"
	@echo "R package update complete. Log: $(R_UPDATE_LOG)"

# Install CRAN/Bioconductor/GitHub R packages
install-packages:
	@echo "Installing R packages..."
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
	@echo "  all                - Create env, fix C++ std, bootstrap, install and update R packages, check logs (default)"
	@echo "  create-env         - Create/update the proteomics conda environment"
	@echo "  fix-cxx-standard   - Set CXX11STD to gnu++14 in R's Makeconf"
	@echo "  bootstrap-packages - Install BiocManager/remotes/pak"
	@echo "  update-packages    - Update installed R packages in proteomics and write update log"
	@echo "  install-packages   - Install R packages listed in PackagesToInstall.txt"
	@echo "  check-logs         - Check logs for failures and clean up if successful"
	@echo "  clean              - Remove log files"
	@echo "  help               - Show this help message"
