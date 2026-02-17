#!/bin/bash
set -e

SITE_ROOT="_site"
mkdir -p "$SITE_ROOT"

# Ensure GitHub Pages processes all files (bypassing Jekyll)
touch "$SITE_ROOT/.nojekyll"

echo "Building All Books..."

# Start creating the index.html content
cat > "$SITE_ROOT/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wombat Worlds Books</title>
    <style>
        body { font-family: system-ui, sans-serif; max-width: 800px; margin: 0 auto; padding: 2rem; background-color: #f4f4f9; color: #333; }
        h1 { color: #2c3e50; border-bottom: 2px solid #2c3e50; padding-bottom: 0.5rem; }
        ul { list-style-type: none; padding: 0; }
        li { margin-bottom: 1rem; background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); transition: transform 0.2s; }
        li:hover { transform: translateY(-2px); }
        a { text-decoration: none; color: #2980b9; font-size: 1.5rem; font-weight: bold; display: block; }
        a:hover { color: #3498db; }
        .book-meta { margin-top: 0.5rem; color: #666; font-size: 0.9rem; }
    </style>
</head>
<body>
    <h1>Available Books</h1>
    <ul>
EOF

# Find all books with a config.yml
for config in books/*/config.yml; do
    if [ -f "$config" ]; then
        book_dir=$(dirname "$config")
        book_id=$(basename "$book_dir")
        
        # Get book title and author from config using yq
        book_title=$(yq -r '.book.title.en // .book.title' "$config")
        book_author=$(yq -r '.book.author' "$config")

        echo "Found book: $book_id"
        ./scripts/build_book_site.sh --book-id "$book_id"

        # Add link to the book in the index
        echo "        <li>" >> "$SITE_ROOT/index.html"
        echo "            <a href=\"books/$book_id/\">$book_title</a>" >> "$SITE_ROOT/index.html"
        if [ "$book_author" != "null" ]; then
            echo "            <div class=\"book-meta\">by $book_author</div>" >> "$SITE_ROOT/index.html"
        fi
        echo "        </li>" >> "$SITE_ROOT/index.html"
    fi
done

# Close the HTML tags
cat >> "$SITE_ROOT/index.html" << EOF
    </ul>
</body>
</html>
EOF

echo "Site build complete in $SITE_ROOT"
