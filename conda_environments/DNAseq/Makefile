.PHONY: all create-env update-packages install-packages check-logs clean help

SHELL := /bin/bash
.SHELLFLAGS := -lc

CRAN_MIRROR ?= https://cloud.r-project.org
R_UPDATE_LOG ?= AllPackageInstallationLogs/00_RPackageUpdate.log

# Default target
all: create-env update-packages install-packages check-logs

# Create/update DNAseq_R conda environment
create-env:
	@echo "Creating conda environment 'DNAseq_R'..."
	@if conda env list | grep -q "^DNAseq_R "; then \
		echo "Environment 'DNAseq_R' already exists. Updating..."; \
		mamba env update -y -f DNAseq_R.yaml --prune; \
	else \
		mamba env create -y -f DNAseq_R.yaml; \
	fi
	@echo "Conda environment 'DNAseq_R' ready."

# Update installed R packages in the conda environment
update-packages:
	@echo "Updating installed R packages in 'DNAseq_R'..."
	@mkdir -p AllPackageInstallationLogs
	@conda run -n DNAseq_R Rscript xUpdateRPackages.R "$(CRAN_MIRROR)" "$(R_UPDATE_LOG)"
	@echo "R package update complete. Log: $(R_UPDATE_LOG)"

# Install GitHub R packages
install-packages:
	@if [[ ! -f PackagesToInstall.txt ]]; then \
		echo "PackagesToInstall.txt not found. Skipping GitHub R package installation."; \
	elif grep -Eq '^[[:space:]]*[^#[:space:]]' PackagesToInstall.txt; then \
		echo "Installing GitHub R packages..."; \
		./xInstallPackages.sh; \
	else \
		echo "No GitHub R packages to install. Skipping."; \
	fi

# Check logs for failures and clean up if successful
check-logs:
	@echo "Checking installation logs for failures..."
	@if [[ ! -f AllPackageInstallationSummary.log ]]; then \
		echo "No installation summary log found. Skipping log check."; \
	elif grep -q "FAILURE" AllPackageInstallationSummary.log; then \
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
	@echo "  all              - Create/update environment, update R packages, install GitHub packages (default)"
	@echo "  create-env       - Create/update the DNAseq_R conda environment"
	@echo "  update-packages  - Update installed R packages in DNAseq_R and write update log"
	@echo "  install-packages - Install GitHub-only R packages (PackagesToInstall.txt)"
	@echo "  check-logs       - Check logs for failures and clean up if successful"
	@echo "  clean            - Remove log files"
	@echo "  help             - Show this help message"
