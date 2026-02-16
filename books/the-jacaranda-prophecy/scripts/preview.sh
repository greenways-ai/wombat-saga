#!/bin/bash
#
# preview.sh - Build and preview the book locally
#
# Usage: ./scripts/preview.sh [language]
#   language: Optional language code (en, es, fr, de). Defaults to en.
#

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOK_DIR="$(dirname "$SCRIPT_DIR")"
BOOK_ID=$(basename "$BOOK_DIR")

# Default to English if no language specified
LANG="${1:-en}"

echo "🚀 Building book preview: $BOOK_ID ($LANG)"

# Check dependencies
command -v pandoc >/dev/null 2>&1 || { echo "Error: pandoc is required. Install with: brew install pandoc (macOS) or apt-get install pandoc (Linux)"; exit 1; }

# Read config
CONFIG_FILE="$BOOK_DIR/config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Get book metadata (requires yq, fallback to grep/sed)
if command -v yq >/dev/null 2>&1; then
    BOOK_TITLE=$(yq e ".book.title.$LANG" "$CONFIG_FILE")
    BOOK_AUTHOR=$(yq e ".book.author" "$CONFIG_FILE")
else
    echo "Warning: yq not installed. Using basic title detection."
    BOOK_TITLE="$BOOK_ID"
    BOOK_AUTHOR="Unknown"
fi

# Create preview directory
PREVIEW_DIR="$BOOK_DIR/_preview/$LANG"
mkdir -p "$PREVIEW_DIR"

# Get source directory
SOURCE_DIR="$BOOK_DIR/$LANG"
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Language directory not found: $SOURCE_DIR"
    exit 1
fi

# Build each chapter
echo "📄 Converting markdown to HTML..."

CHAPTER_FILES=$(find "$SOURCE_DIR" -name "*.md" -type f | sort)

for FILE in $CHAPTER_FILES; do
    BASENAME=$(basename "$FILE" .md)
    OUTPUT="$PREVIEW_DIR/${BASENAME}.html"
    
    echo "  → $BASENAME.md"
    
    pandoc \
        --from markdown+yaml_metadata_block \
        --to html5 \
        --output "$OUTPUT" \
        --standalone \
        --metadata title="$BOOK_TITLE" \
        --metadata author="$BOOK_AUTHOR" \
        --metadata lang="$LANG" \
        --css=preview.css \
        "$FILE" 2>/dev/null || \
    pandoc \
        --from markdown+yaml_metadata_block \
        --to html5 \
        --output "$OUTPUT" \
        --standalone \
        --metadata title="$BOOK_TITLE" \
        --metadata author="$BOOK_AUTHOR" \
        --metadata lang="$LANG" \
        "$FILE"
done

# Create simple CSS
cat > "$PREVIEW_DIR/preview.css" << 'EOF'
body {
    font-family: Georgia, "Times New Roman", serif;
    font-size: 18px;
    line-height: 1.8;
    max-width: 720px;
    margin: 0 auto;
    padding: 2rem;
    color: #333;
    background: #faf8f5;
}

h1, h2, h3, h4 {
    font-weight: 600;
    line-height: 1.3;
    margin-top: 2rem;
    margin-bottom: 1rem;
}

h1 { font-size: 2rem; }
h2 { font-size: 1.5rem; }
h3 { font-size: 1.25rem; }

p {
    margin-bottom: 1.2rem;
    text-align: justify;
}

blockquote {
    margin: 1.5rem 0;
    padding: 0.5rem 1.5rem;
    border-left: 3px solid #e74c3c;
    font-style: italic;
    color: #555;
}

hr {
    border: none;
    text-align: center;
    margin: 2rem 0;
}

hr::after {
    content: "* * *";
    letter-spacing: 1em;
    color: #999;
}

nav.preview-nav {
    display: flex;
    justify-content: space-between;
    margin-top: 3rem;
    padding-top: 2rem;
    border-top: 1px solid #ddd;
}

nav.preview-nav a {
    color: #667eea;
    text-decoration: none;
}

nav.preview-nav a:hover {
    text-decoration: underline;
}

@media print {
    nav.preview-nav { display: none; }
}
EOF

# Create index with navigation
echo "🔗 Creating index..."

INDEX_FILE="$PREVIEW_DIR/index.html"
FIRST_FILE=$(echo "$CHAPTER_FILES" | head -1 | xargs basename -s .md)

cat > "$INDEX_FILE" << EOF
<!DOCTYPE html>
<html lang="$LANG">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$BOOK_TITLE - Preview</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 3rem 1rem;
            background: #f5f5f5;
        }
        .container {
            background: white;
            border-radius: 12px;
            padding: 3rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        h1 { margin-bottom: 0.5rem; }
        .author { color: #666; margin-bottom: 2rem; }
        .chapters {
            list-style: none;
            padding: 0;
        }
        .chapters li {
            margin: 0.5rem 0;
        }
        .chapters a {
            display: block;
            padding: 0.75rem 1rem;
            background: #f8f9fa;
            border-radius: 6px;
            text-decoration: none;
            color: #333;
            transition: background 0.2s;
        }
        .chapters a:hover {
            background: #e9ecef;
        }
        .actions {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
        }
        .btn {
            display: inline-block;
            padding: 0.75rem 1.5rem;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 6px;
            margin-right: 0.5rem;
        }
        .btn:hover {
            background: #5a6fd6;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$BOOK_TITLE</h1>
        <p class="author">by $BOOK_AUTHOR</p>
        
        <h2>Chapters</h2>
        <ul class="chapters">
EOF

# Add chapters to index
for FILE in $CHAPTER_FILES; do
    BASENAME=$(basename "$FILE" .md)
    # Try to get title from frontmatter
    TITLE=$(grep -m1 "^title:" "$FILE" 2>/dev/null | sed 's/title: *//' | sed 's/["'"'"]//g' | xargs || echo "$BASENAME")
    echo "            <li><a href=\"${BASENAME}.html\">$TITLE</a></li>" >> "$INDEX_FILE"
done

cat >> "$INDEX_FILE" << EOF
        </ul>
        
        <div class="actions">
            <a href="${FIRST_FILE}.html" class="btn">Start Reading →</a>
            <a href="../" class="btn" style="background: #6c757d;">← Back</a>
        </div>
    </div>
</body>
</html>
EOF

# Add navigation to each chapter
PREV_FILE=""
for FILE in $CHAPTER_FILES; do
    BASENAME=$(basename "$FILE" .md)
    HTML_FILE="$PREVIEW_DIR/${BASENAME}.html"
    
    # Get next file
    NEXT_FILE=$(echo "$CHAPTER_FILES" | grep -A1 "$FILE" | tail -1 | xargs basename -s .md 2>/dev/null || echo "")
    if [ "$NEXT_FILE" = "$BASENAME" ]; then
        NEXT_FILE=""
    fi
    
    # Add navigation
    NAV_HTML="<nav class=\"preview-nav\">"
    if [ -n "$PREV_FILE" ]; then
        NAV_HTML="$NAV_HTML<a href=\"${PREV_FILE}.html\">← Previous</a>"
    else
        NAV_HTML="$NAV_HTML<span></span>"
    fi
    NAV_HTML="$NAV_HTML<a href=\"index.html\">Contents</a>"
    if [ -n "$NEXT_FILE" ]; then
        NAV_HTML="$NAV_HTML<a href=\"${NEXT_FILE}.html\">Next →</a>"
    else
        NAV_HTML="$NAV_HTML<span></span>"
    fi
    NAV_HTML="$NAV_HTML</nav>"
    
    # Insert before closing body tag
    if [ -f "$HTML_FILE" ]; then
        # macOS sed requires different syntax
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|</body>|${NAV_HTML}</body>|" "$HTML_FILE"
        else
            sed -i "s|</body>|${NAV_HTML}</body>|" "$HTML_FILE"
        fi
    fi
    
    PREV_FILE="$BASENAME"
done

echo ""
echo "✅ Preview built successfully!"
echo ""
echo "📂 Location: $PREVIEW_DIR"
echo "🌐 Open: file://$PREVIEW_DIR/index.html"
echo ""

# Try to open in browser (macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Opening in browser..."
    open "$PREVIEW_DIR/index.html"
fi

echo "To preview other languages:"
echo "  ./scripts/preview.sh es    # Spanish"
echo "  ./scripts/preview.sh fr    # French"
echo "  ./scripts/preview.sh de    # German"
