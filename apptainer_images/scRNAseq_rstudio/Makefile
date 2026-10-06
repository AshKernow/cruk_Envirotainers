.PHONY: all docker sif check clean clean-docker help

SHELL := /bin/bash

# R version is taken from the rocker/rstudio tag in the Dockerfile, so bumping
# the FROM line is all that's needed to build a new version. Override with
# `make VERSION=x.y.z` if required.
VERSION ?= $(shell sed -n 's|^FROM rocker/rstudio:\([^ ]*\).*|\1|p' Dockerfile)

DOCKER ?= sudo docker
SINGULARITY ?= singularity
SUDO_SINGULARITY ?= sudo $(SINGULARITY)

IMAGE := scrnaseq_rstudio:v$(VERSION)
SIF := rstudio_scRNAseq_$(VERSION).sif

# Files that are baked into the image; changing any of them triggers a rebuild
BUILD_DEPS := Dockerfile xrSCvelo.R

ifeq ($(VERSION),)
$(error Could not determine VERSION from Dockerfile; set it with `make VERSION=x.y.z`)
endif

# Default target
all: sif check

# Build the Docker image
docker:
	@echo "Building Docker image '$(IMAGE)'..."
	$(DOCKER) build -t $(IMAGE) .
	@echo "Docker image '$(IMAGE)' ready."

# Build the Singularity image from the local Docker daemon
sif: $(SIF)

$(SIF): $(BUILD_DEPS)
	@$(MAKE) --no-print-directory docker
	@echo "Building Singularity image '$(SIF)'..."
	$(SUDO_SINGULARITY) build --force $(SIF) docker-daemon://$(IMAGE)
	@echo "Singularity image '$(SIF)' ready."

# Check that all packages in scRNAseqPackages.txt load in the image
check: $(SIF)
	@echo "Checking package installation in '$(SIF)'..."
	$(SINGULARITY) exec \
		--bind $(CURDIR) \
		--pwd $(CURDIR) \
		$(SIF) \
		./xrCheckPackages.R

# Remove the Singularity image
clean:
	@echo "Removing '$(SIF)'..."
	@rm -f $(SIF)

# Remove the Docker image
clean-docker:
	@echo "Removing Docker image '$(IMAGE)'..."
	-$(DOCKER) rmi $(IMAGE)

# Help target
help:
	@echo "Building version $(VERSION) (from Dockerfile)"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Build the Singularity image and check packages (default)"
	@echo "  docker       - Build the Docker image $(IMAGE)"
	@echo "  sif          - Build $(SIF) (rebuilds Docker image first if needed)"
	@echo "  check        - Check all packages in scRNAseqPackages.txt load in the image"
	@echo "  clean        - Remove $(SIF)"
	@echo "  clean-docker - Remove the Docker image $(IMAGE)"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables (override with make VAR=value):"
	@echo "  VERSION      - R/rocker version (default: from Dockerfile FROM line)"
	@echo "  DOCKER       - Docker command (default: sudo docker)"
	@echo "  SINGULARITY  - Singularity/apptainer command (default: singularity)"
