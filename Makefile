SHELL := /bin/bash

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PROFILE = default
PROJECT_NAME = my_google_location_analysis
PYTHON_INTERPRETER = python3

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Set up Python Interpreter Environment with venv
create_environment:
	$(PYTHON_INTERPRETER) -m venv .venv
	@echo ">>> New venv created. NB! Activate it with: source .vev/bin/activate"


## Install python project dependencies
install_requirements: create_environment
	source .venv/bin/activate && $(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	source .venv/bin/activate && $(PYTHON_INTERPRETER) -m pip install -r requirements.txt

FILE_NAME := "TM_WORLD_BORDERS.zip"
## Get dataset for visualization the map of the world
get_world_data:
	mkdir -p ./data/raw
	wget http://thematicmapping.org/downloads/TM_WORLD_BORDERS-0.3.zip -O ./data/raw/$(FILE_NAME)
	unzip ./data/raw/$(FILE_NAME) -d ./data/raw

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
lint:
	flake8 src


.PHONY: help
## print help on makefile
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
