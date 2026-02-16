BOOK_ID ?= the-jacaranda-prophecy
LANGS ?= all
FORMATS ?= epub,pdf,html
OS_NAME := $(shell uname -s)

.PHONY: help install check site book book-site clean all

help:
	@echo "Available targets:"
	@echo "  make install               - Install system dependencies (pandoc, yq, markdownlint)"
	@echo "  make check                 - Run CI checks (linting, stats)"
	@echo "  make site                  - Build the static site structure"
	@echo "  make book                  - Build book artifacts (epub, pdf, html)"
	@echo "                               Usage: make book BOOK_ID=sample-book LANGS=all FORMATS=epub,pdf,html"
	@echo "  make book-site             - Build the web-viewable book site"
	@echo "                               Usage: make book-site BOOK_ID=sample-book"
	@echo "  make clean                 - Remove build artifacts"
	@echo "  make all                   - Run checks and build site"

install:
	@echo "Installing dependencies for $(OS_NAME)..."
	@if [ "$(OS_NAME)" = "Darwin" ]; then \
		if command -v brew >/dev/null 2>&1; then \
			brew install pandoc yq node basictex; \
			npm install -g markdownlint-cli; \
		else \
			echo "Homebrew not found. Please install Homebrew or manually install: pandoc, yq, node, markdownlint-cli"; \
			exit 1; \
		fi \
	elif [ "$(OS_NAME)" = "Linux" ]; then \
		sudo apt-get update && sudo apt-get install -y pandoc yq nodejs npm; \
		sudo npm install -g markdownlint-cli; \
	else \
		echo "Unsupported OS: $(OS_NAME)"; \
		exit 1; \
	fi
	@echo "Dependencies installed successfully."

check:
	@./scripts/run_checks.sh

site:
	@./scripts/build_site.sh

book:
	@./scripts/build_book.sh --book-id "$(BOOK_ID)" --langs "$(LANGS)" --formats "$(FORMATS)"

book-site:
	@./scripts/build_book_site.sh --book-id "$(BOOK_ID)"

clean:
	@echo "Cleaning up..."
	@rm -rf _site build site stats.txt
	@echo "Done."

all: check site