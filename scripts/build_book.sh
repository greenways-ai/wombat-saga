#!/bin/bash
set -e

# Helper function to check dependencies
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

# Defaults
BOOK_ID="sample-book"
LANGUAGES="all"
FORMATS="epub,pdf,html"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --book-id) BOOK_ID="$2"; shift ;;
        --langs) LANGUAGES="$2"; shift ;;
        --formats) FORMATS="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;; 
    esac
    shift
done

CONFIG_FILE="books/$BOOK_ID/config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

# Resolve Languages
if [ "$LANGUAGES" = "all" ]; then
    LANGUAGES=$(yq -r '.languages | keys | .[]' "$CONFIG_FILE")
else
    # Replace commas with spaces
    LANGUAGES=${LANGUAGES//,/ }
fi

# Resolve Formats
if [ "$FORMATS" = "all" ]; then
    FORMATS=$(yq -r '.outputs | to_entries | map(select(.value.enabled == true)) | .[].key' "$CONFIG_FILE")
else
    FORMATS=${FORMATS//,/ }
fi

echo "Building Book: $BOOK_ID"
echo "Languages: $LANGUAGES"
echo "Formats: $FORMATS"

for LANG in $LANGUAGES; do
    echo "Processing Language: $LANG"
    
    # Check if language dir exists
    LANG_DIR="books/$BOOK_ID/$LANG"
    if [ ! -d "$LANG_DIR" ]; then
        echo "Warning: Directory $LANG_DIR does not exist. Skipping."
        continue
    fi

    # Create build dir
    BUILD_DIR="build/$BOOK_ID/$LANG"
    mkdir -p "$BUILD_DIR"
    
    # Gather files
    # We use yq to get the file list in order from the structure
    FILES=$(yq -r '.structure[] | .chapters[] | select(.type != "cover" and .type != "toc") | .file' "$CONFIG_FILE")
    
    # Copy files to build dir
    for file in $FILES; do
        SRC="books/$BOOK_ID/$LANG/$file"
        if [ -f "$SRC" ]; then
            cp "$SRC" "$BUILD_DIR/"
        else
            echo "Warning: File $SRC missing."
        fi
    done
    
    TITLE=$(yq -r ".book.title.$LANG" "$CONFIG_FILE")
    AUTHOR=$(yq -r ".book.author" "$CONFIG_FILE")
    
    # Build Formats
    for FMT in $FORMATS; do
        echo "  Building $FMT..."
        case $FMT in
            epub)
                pandoc \
                    --from markdown+yaml_metadata_block \
                    --to epub \
                    --output "build/${BOOK_ID}-${LANG}.epub" \
                    --metadata title="$TITLE" \
                    --metadata author="$AUTHOR" \
                    --metadata language="$LANG" \
                    --toc \
                    --toc-depth=2 \
                    --epub-cover-image="books/$BOOK_ID/assets/covers/cover-${LANG}.png" \
                    "$BUILD_DIR"/*.md || echo "    Failed to build EPUB"
                ;;
            pdf)
                # Check for xelatex if PDF is requested
                if command -v xelatex &> /dev/null; then
                    pandoc \
                        --from markdown+yaml_metadata_block \
                        --to pdf \
                        --output "build/${BOOK_ID}-${LANG}.pdf" \
                        --metadata title="$TITLE" \
                        --metadata author="$AUTHOR" \
                        --metadata lang="$LANG" \
                        --toc \
                        --toc-depth=2 \
                        --pdf-engine=xelatex \
                        --template="books/$BOOK_ID/assets/templates/pdf-template.latex" \
                        -V geometry:margin=1in \
                        -V documentclass=book \
                        "$BUILD_DIR"/*.md || echo "    Failed to build PDF"
                else
                    echo "    Skipping PDF: xelatex not found."
                fi
                ;;
            html)
                pandoc \
                    --from markdown+yaml_metadata_block \
                    --to html5 \
                    --output "build/${BOOK_ID}-${LANG}.html" \
                    --metadata title="$TITLE" \
                    --metadata author="$AUTHOR" \
                    --metadata lang="$LANG" \
                    --standalone \
                    --template="books/$BOOK_ID/assets/templates/html-template.html" \
                    --toc \
                    --toc-depth=2 \
                    "$BUILD_DIR"/*.md || echo "    Failed to build HTML"
                ;;
        esac
    done
done

echo "Build complete. Artifacts in 'build/'"
