#!/bin/bash
set -e

# Defaults
SITE_DIR="site"
mkdir -p "$SITE_DIR"

echo "Building Site Structure in $SITE_DIR..."

# Create index page
cat > "$SITE_DIR/index.md" << 'EOF'
# The Wombat Worlds Saga

**A Narrative Simulation of Arnamland**

Welcome to the Wombat Worlds Saga — a story about Hoebat, a wombat architect
fighting to save his city from the Great Crystalisation.

## Start Reading

- [Meta-Narrative](meta-narrative.md) — The themes and philosophy
- [Lore](lore.md) — The world of Arnamland
- [Story](storyline.md) — The narrative arc
- [Characters](characters.md) — The cast

## The Story

In the underground city of Melborow, wombats have forgotten the Old Ways.
The Five Sovereigns rule with their Frequency, their Walls, their Ledger.
But in the shadows, Hoebat and the Kappa Mu squad work to hold the world together.

> *"Are you servicing the land?"*
EOF

# Copy main content files
echo "Copying main files..."
cp wombat-saga/*.md "$SITE_DIR/" 2>/dev/null || true

# Copy subdirectories
for dir in stories lore characters locations songs plot groups constants; do
    if [ -d "wombat-saga/$dir" ]; then
        echo "Copying $dir..."
        mkdir -p "$SITE_DIR/$dir"
        cp wombat-saga/$dir/*.md "$SITE_DIR/$dir/" 2>/dev/null || true
    fi
done

echo "Site preparation complete in $SITE_DIR"
echo "You can now run a static site generator (like mdbook or jekyll) on this directory."
