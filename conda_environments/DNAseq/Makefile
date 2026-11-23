# DNAseq conda environments. Shared recipes and scripts live in
# ../R_build_common (see the README there).
include ../R_build_common/R_env.mk

R_ENV := DNAseq_R
TOOLS_ENV := DNAseq_Tools
PYTHON_ENV := DNAseq_Python
PKG_LIST := PackagesToInstall.txt

.PHONY: all create-r create-env create-tools-env create-python-env update-packages install-packages check-logs clean help

# Default target
all: create-env create-tools-env create-python-env update-packages install-packages check-logs

# Create/update only the R environment and run R package steps
create-r: create-env update-packages install-packages check-logs

create-env:
	$(call create_conda_env,$(R_ENV),$(R_ENV).yaml)

create-tools-env:
	$(call create_conda_env,$(TOOLS_ENV),$(TOOLS_ENV).yaml)

create-python-env:
	$(call create_conda_env,$(PYTHON_ENV),$(PYTHON_ENV).yaml)

update-packages:
	$(call update_r_pkgs,$(R_ENV),$(R_UPDATE_LOG))

install-packages:
	$(call install_r_pkgs,$(R_ENV),$(PKG_LIST),$(R_LOG_DIR),$(R_SUMMARY_LOG))

check-logs:
	$(call check_r_logs,$(R_LOG_DIR),$(R_SUMMARY_LOG))

clean:
	$(call clean_r_logs,$(R_LOG_DIR),$(R_SUMMARY_LOG))

help:
	@echo "Available targets:"
	@echo "  all               - Create/update all environments, then run all R package steps (default)"
	@echo "  create-r          - Create/update $(R_ENV) and run the R package steps only"
	@echo "  create-env        - Create/update the $(R_ENV) conda environment"
	@echo "  create-tools-env  - Create/update the $(TOOLS_ENV) conda environment"
	@echo "  create-python-env - Create/update the $(PYTHON_ENV) conda environment"
	@echo "  update-packages   - Update installed R packages in $(R_ENV) and write update log"
	@echo "  install-packages  - Install GitHub-only R packages ($(PKG_LIST))"
	@echo "  check-logs        - Check logs for failures and clean up if successful"
	@echo "  clean             - Remove log files"
	@echo "  help              - Show this help message"
