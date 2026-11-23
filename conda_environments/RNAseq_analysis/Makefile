# RNAseq conda environments. Shared recipes and scripts live in
# ../R_build_common (see the README there).
include ../R_build_common/R_env.mk

R_ENV := RNAseq_R
PYTHON_ENV := RNAseq_Python
TOOLS_ENV := RNAseq_Tools
PKG_LIST := PackagesToInstall.txt

# R 4.6 build: a separate environment/yaml/package-list living alongside the
# existing RNAseq_R environment (which stays untouched for ongoing projects).
# None of the bioconductor-*/r-* conda packages have R 4.6 builds yet, so
# they're installed manually via BiocManager::install() (see
# PackagesToInstall_R4.6.txt) instead of via RNAseq_R4.6.yaml.
R46_ENV := RNAseq_R4.6
R46_PKGLIST := PackagesToInstall_R4.6.txt
R46_LOGDIR := AllPackageInstallationLogs_R4.6
R46_SUMMARY := AllPackageInstallationSummary_R4.6.log
R46_UPDATE_LOG ?= $(R46_LOGDIR)/00_RPackageUpdate.log

.PHONY: all create-r create-env-r create-env-python create-env-tools fix-cxx-standard update-packages install-packages check-logs clean help \
        create-r4.6 create-env-r4.6 fix-cxx-standard-r4.6 bootstrap-r4.6 update-packages-r4.6 install-packages-r4.6 check-logs-r4.6 clean-r4.6

# Default target
all: create-env-r create-env-python create-env-tools fix-cxx-standard update-packages install-packages check-logs create-r4.6

# R-only build (skips Python and Tools environments)
create-r: create-env-r fix-cxx-standard update-packages install-packages check-logs

create-env-r:
	$(call create_conda_env,$(R_ENV),$(R_ENV).yaml)

create-env-tools:
	$(call create_conda_env,$(TOOLS_ENV),$(TOOLS_ENV).yaml)

create-env-python:
	$(call create_conda_env,$(PYTHON_ENV),$(PYTHON_ENV).yaml)

fix-cxx-standard:
	$(call fix_cxx_standard,$(R_ENV))

update-packages:
	$(call update_r_pkgs,$(R_ENV),$(R_UPDATE_LOG))

install-packages:
	$(call install_r_pkgs,$(R_ENV),$(PKG_LIST),$(R_LOG_DIR),$(R_SUMMARY_LOG))

check-logs:
	$(call check_r_logs,$(R_LOG_DIR),$(R_SUMMARY_LOG))

clean:
	$(call clean_r_logs,$(R_LOG_DIR),$(R_SUMMARY_LOG))

# --- R 4.6 build (separate environment, does not touch RNAseq_R) ---

create-r4.6: create-env-r4.6 fix-cxx-standard-r4.6 bootstrap-r4.6 install-packages-r4.6 update-packages-r4.6 check-logs-r4.6

create-env-r4.6:
	$(call create_conda_env,$(R46_ENV),$(R46_ENV).yaml)

fix-cxx-standard-r4.6:
	$(call fix_cxx_standard,$(R46_ENV))

bootstrap-r4.6:
	$(call bootstrap_r_pkgs,$(R46_ENV))

install-packages-r4.6:
	$(call install_r_pkgs,$(R46_ENV),$(R46_PKGLIST),$(R46_LOGDIR),$(R46_SUMMARY))

update-packages-r4.6:
	$(call update_r_pkgs,$(R46_ENV),$(R46_UPDATE_LOG))

check-logs-r4.6:
	$(call check_r_logs,$(R46_LOGDIR),$(R46_SUMMARY))

clean-r4.6:
	$(call clean_r_logs,$(R46_LOGDIR),$(R46_SUMMARY))

help:
	@echo "Available targets:"
	@echo "  all                   - Create/update all environments (incl. $(R46_ENV)), update R packages, install GitHub packages (default)"
	@echo "  create-r              - R-only build: create $(R_ENV), fix C++ standard, update and install R packages"
	@echo "  create-env-r          - Create/update the $(R_ENV) conda environment"
	@echo "  create-env-python     - Create/update the $(PYTHON_ENV) conda environment"
	@echo "  create-env-tools      - Create/update the $(TOOLS_ENV) conda environment (fastqc, salmon, multiqc, picard)"
	@echo "  update-packages       - Update installed R packages in $(R_ENV) and write update log"
	@echo "  install-packages      - Install GitHub-only R packages ($(PKG_LIST))"
	@echo "  fix-cxx-standard      - Set CXX11STD=C++14 in $(R_ENV)'s R Makeconf (fixes RcppArmadillo build)"
	@echo "  check-logs            - Check logs for failures and clean up if successful"
	@echo "  clean                 - Remove log files"
	@echo "  create-r4.6           - R 4.6 build: create $(R46_ENV) (separate env), install/update R packages"
	@echo "  create-env-r4.6       - Create/update the $(R46_ENV) conda environment"
	@echo "  fix-cxx-standard-r4.6 - Set CXX11STD=C++14 in $(R46_ENV)'s R Makeconf"
	@echo "  bootstrap-r4.6        - Install BiocManager/remotes/pak into $(R46_ENV) (no R 4.6 conda builds yet)"
	@echo "  install-packages-r4.6 - Install CRAN/Bioconductor/GitHub R packages into $(R46_ENV) ($(R46_PKGLIST))"
	@echo "  update-packages-r4.6  - Update installed R packages in $(R46_ENV) and write update log"
	@echo "  check-logs-r4.6       - Check $(R46_ENV) logs for failures and clean up if successful"
	@echo "  clean-r4.6            - Remove $(R46_ENV) log files"
	@echo "  help                  - Show this help message"
