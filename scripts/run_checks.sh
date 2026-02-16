#!/bin/bash
set -e

echo "Running CI Checks..."

# Markdown Lint
if command -v markdownlint &> /dev/null; then
    echo "Running markdownlint..."
    markdownlint "wombat-saga/**/*.md" \
        --ignore "wombat-saga/wattpad/**" \
        --ignore "wombat-saga/drafts/**" \
        --config .github/markdownlint.json || echo "Markdownlint found issues (non-fatal for script)"
else
    echo "markdownlint not found. Skipping linting."
fi

# Word Count Stats
echo "Generating Stats..."
STATS_FILE="stats.txt"
echo "## Word Count Statistics" > "$STATS_FILE"
echo "" >> "$STATS_FILE"

echo "### By Category" >> "$STATS_FILE"
echo "" >> "$STATS_FILE"

for dir in stories lore characters locations songs plot; do
    if [ -d "wombat-saga/$dir" ]; then
        count=$(find "wombat-saga/$dir" -name "*.md" -exec cat {} \; | wc -w)
        echo "- **$dir**: $count words" >> "$STATS_FILE"
    fi
done

# Total
total=$(find wombat-saga -name "*.md" -not -path "*/drafts/*" -not -path "*/wattpad/*" -exec cat {} \; | wc -w)
echo "" >> "$STATS_FILE"
echo "### Total: $total words" >> "$STATS_FILE"

cat "$STATS_FILE"
echo "Stats saved to $STATS_FILE"
