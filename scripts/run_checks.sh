#!/bin/bash
set -e

echo "Running CI Checks on books/..."

# Markdown Lint
if command -v markdownlint &> /dev/null; then
    echo "Running markdownlint..."
    markdownlint "books/**/*.md" \
        --ignore "books/**/assets/**" \
        --ignore "books/**/scripts/**" \
        --config .github/markdownlint.json || echo "Markdownlint found issues (non-fatal for script)"
else
    echo "markdownlint not found. Skipping linting."
fi

# Word Count Stats
echo "Generating Stats..."
STATS_FILE="stats.txt"
echo "## Word Count Statistics" > "$STATS_FILE"
echo "" >> "$STATS_FILE"

echo "### By Book" >> "$STATS_FILE"
echo "" >> "$STATS_FILE"

# Find all book directories
for book_dir in books/*; do
    if [ -d "$book_dir" ] && [ -f "$book_dir/config.yml" ]; then
        book_id=$(basename "$book_dir")
        
        # Count words in markdown files for this book
        count=$(find "$book_dir" -name "*.md" -exec cat {} \; | wc -w)
        echo "- **$book_id**: $count words" >> "$STATS_FILE"
    fi
done

# Total
total=$(find books -name "*.md" -not -path "*/assets/*" -exec cat {} \; | wc -w)
echo "" >> "$STATS_FILE"
echo "### Total: $total words" >> "$STATS_FILE"

cat "$STATS_FILE"
echo "Stats saved to $STATS_FILE"
