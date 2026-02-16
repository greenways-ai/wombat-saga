#!/bin/bash
set -e

SITE_ROOT="_site"
mkdir -p "$SITE_ROOT"

echo "Building All Books..."

# Find all books with a config.yml
for config in books/*/config.yml; do
    if [ -f "$config" ]; then
        book_dir=$(dirname "$config")
        book_id=$(basename "$book_dir")
        
        echo "Found book: $book_id"
        ./scripts/build_book_site.sh --book-id "$book_id"
    fi
done

echo "Site build complete in $SITE_ROOT"
