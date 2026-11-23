# Proteomics conda environment. Shared recipes and scripts live in
# ../R_build_common (see the README there).
include ../R_build_common/R_env.mk

R_ENV := proteomics
PKG_LIST := PackagesToInstall.txt

.PHONY: all create-env fix-cxx-standard bootstrap-packages update-packages install-packages check-logs clean help

# Default target
all: create-env fix-cxx-standard bootstrap-packages install-packages update-packages check-logs

create-env:
	$(call create_conda_env,$(R_ENV),$(R_ENV).yaml)

fix-cxx-standard:
	$(call fix_cxx_standard,$(R_ENV))

bootstrap-packages:
	$(call bootstrap_r_pkgs,$(R_ENV))

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
	@echo "  all                - Create env, fix C++ std, bootstrap, install and update R packages, check logs (default)"
	@echo "  create-env         - Create/update the $(R_ENV) conda environment"
	@echo "  fix-cxx-standard   - Set CXX11STD to gnu++14 in R's Makeconf"
	@echo "  bootstrap-packages - Install BiocManager/remotes/pak"
	@echo "  update-packages    - Update installed R packages in $(R_ENV) and write update log"
	@echo "  install-packages   - Install R packages listed in $(PKG_LIST)"
	@echo "  check-logs         - Check logs for failures and clean up if successful"
	@echo "  clean              - Remove log files"
	@echo "  help               - Show this help message"
