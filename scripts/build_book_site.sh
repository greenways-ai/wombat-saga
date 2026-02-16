#!/bin/bash
set -e

check_deps() {
    local missing=0
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: '$cmd' is not installed."
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        exit 1
    fi
}

check_deps yq pandoc

BOOK_ID="sample-book"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --book-id) BOOK_ID="$2"; shift ;; 
        *) echo "Unknown parameter: $1"; exit 1 ;; 
    esac
    shift
done

CONFIG_FILE="books/$BOOK_ID/config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

SITE_DIR="_site/books/$BOOK_ID"
mkdir -p "$SITE_DIR"

BOOK_TITLE=$(yq e '.book.title.en' "$CONFIG_FILE")
BOOK_AUTHOR=$(yq e '.book.author' "$CONFIG_FILE")
LANGUAGES=$(yq e '.languages | keys | .[]' "$CONFIG_FILE")

echo "Building Book Site: $BOOK_ID"
echo "Languages: $LANGUAGES"

for LANG in $LANGUAGES; do
    echo "Processing language: $LANG"
    
    LANG_DIR="books/$BOOK_ID/$LANG"
    if [ ! -d "$LANG_DIR" ]; then
        echo "Warning: Language directory not found: $LANG_DIR"
        continue
    fi
    
    LANG_TITLE=$(yq e ".book.title.$LANG" "$CONFIG_FILE")
    [ "$LANG_TITLE" = "null" ] && LANG_TITLE="$BOOK_TITLE"
    
    LANG_SITE_DIR="$SITE_DIR/$LANG"
    mkdir -p "$LANG_SITE_DIR"
    
    # Get chapter files
    CHAPTER_FILES=$(find "$LANG_DIR" -name "*.md" -type f | sort)
    
    # Build chapters.json
    echo "  Generating chapters.json..."
    {
        echo "{"
        echo '  "bookId": "'$BOOK_ID'",'
        echo '  "lang": "'$LANG'",'
        echo '  "title": "'$LANG_TITLE'",'
        echo '  "author": "'$BOOK_AUTHOR'",'
        echo '  "chapters": ['
        
        FIRST=true
        for FILE in $CHAPTER_FILES; do
            BASENAME=$(basename "$FILE" .md)
            CHAPTER_TITLE=$(grep -m1 "^title:" "$FILE" 2>/dev/null | sed 's/title: *//' | sed 's/["'"]//g' | xargs || echo "$BASENAME")
            
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo ","
            fi
            echo -n '    {"file": "'$BASENAME'.html", "title": "'$CHAPTER_TITLE'"}'
            
            # Convert to HTML
            pandoc \
                --from markdown+yaml_metadata_block \
                --to html5 \
                --output "$LANG_SITE_DIR/${BASENAME}.html" \
                --metadata title="$CHAPTER_TITLE" \
                --metadata lang="$LANG" \
                --wrap=none \
                --no-highlight \
                "$FILE"
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$LANG_SITE_DIR/chapters.json"
    
    # Create index.html for Language
    cat > "$LANG_SITE_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="$LANG">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$LANG_TITLE</title>
  <link rel="stylesheet" href="../assets/book.css">
</head>
<body>
  <div class="book-container">
    <nav class="book-sidebar">
      <div class="sidebar-header">
        <h1 class="book-title">$LANG_TITLE</h1>
        <p class="book-author">$BOOK_AUTHOR</p>
        <div class="language-selector">
          <select id="lang-select" aria-label="Select language"></select>
        </div>
      </div>
      <div class="toc" id="toc"></div>
    </nav>
    <main class="book-content">
      <div id="chapter-content"><div class="loading">Loading...</div></div>
      <nav class="chapter-nav">
        <button id="prev-btn" class="nav-btn" disabled>Previous</button>
        <a href="../" class="nav-btn">All Books</a>
        <button id="next-btn" class="nav-btn" disabled>Next</button>
      </nav>
    </main>
  </div>
  <script src="../assets/book.js"></script>
</body>
</html>
EOF

done

# Copy shared assets
mkdir -p "$SITE_DIR/assets"
if [ -d ".github/workflows/templates" ]; then
    cp .github/workflows/templates/book.css "$SITE_DIR/assets/"
    cp .github/workflows/templates/book.js "$SITE_DIR/assets/"
else
    echo "Warning: Templates directory not found at .github/workflows/templates"
fi

# Create languages.json
echo "Generating languages.json..."
{
    echo "["
    FIRST_LANG=true
    for LANG in $LANGUAGES; do
        LANG_NAME=$(yq e ".languages.\"$LANG\".name" "$CONFIG_FILE")
        if [ "$FIRST_LANG" = true ]; then
            FIRST_LANG=false
        else
            echo ","
        fi
        echo -n '{"code": "'$LANG'", "name": "'$LANG_NAME'"}'
    done
    echo ""
    echo "]"
} > "$SITE_DIR/languages.json"

# Create Book Landing Page
echo "Generating book landing page..."
cat > "$SITE_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$BOOK_TITLE</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    .book-card {
      background: white;
      border-radius: 16px;
      padding: 3rem;
      max-width: 600px;
      width: 100%;
      box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    }
    h1 { font-size: 2.5rem; margin-bottom: 0.5rem; color: #333; }
    .author { color: #666; margin-bottom: 2rem; font-size: 1.1rem; }
    .languages { margin-top: 2rem; }
    .languages h2 {
      font-size: 1rem;
      text-transform: uppercase;
      letter-spacing: 0.1em;
      color: #999;
      margin-bottom: 1rem;
    }
    .lang-list { display: flex; flex-wrap: wrap; gap: 0.75rem; }
    .lang-btn {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1.5rem;
      background: #f5f5f5;
      border-radius: 8px;
      text-decoration: none;
      color: #333;
      font-weight: 500;
      transition: all 0.2s;
    }
    .lang-btn:hover { background: #667eea; color: white; transform: translateY(-2px); }
    .lang-code { font-size: 0.75rem; opacity: 0.6; text-transform: uppercase; }
    .back-link { display: inline-block; margin-top: 2rem; color: #667eea; text-decoration: none; }
    .back-link:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <div class="book-card">
    <h1>$BOOK_TITLE</h1>
    <p class="author">by $BOOK_AUTHOR</p>
    <div class="languages">
      <h2>Choose your language</h2>
      <div class="lang-list">
EOF

for LANG in $LANGUAGES; do
    LANG_NAME=$(yq e ".languages.\"$LANG\".name" "$CONFIG_FILE")
    echo "        <a href=\"$LANG/\" class=\"lang-btn\"><span>$LANG_NAME</span><span class=\"lang-code\">$LANG</span></a>" >> "$SITE_DIR/index.html"
done

cat >> "$SITE_DIR/index.html" << EOF
      </div>
    </div>
    <a href="../" class="back-link">All Books</a>
  </div>
</body>
</html>
EOF

echo "Book Site built in $SITE_DIR"
