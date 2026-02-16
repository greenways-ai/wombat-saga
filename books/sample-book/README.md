# Sample Book: Multi-Language Publishing Scaffold

This directory contains a complete scaffolding for publishing a book in multiple languages using GitHub Actions.

## Directory Structure

```
books/sample-book/
├── config.yml              # Main configuration file
├── README.md               # This file
├── en/                     # English (original) content
│   ├── 00-cover.md
│   ├── 00-title.md
│   ├── 00-toc.md
│   ├── 00-dedication.md
│   ├── 01-chapter.md
│   ├── 02-chapter.md
│   ├── 03-chapter.md
│   ├── 04-chapter.md
│   ├── 99-glossary.md
│   └── 99-about.md
├── es/                     # Spanish translation
├── fr/                     # French translation
├── de/                     # German translation
├── translations/           # Translation management files
│   ├── glossary/           # Translation glossaries
│   ├── tm/                 # Translation memory files
│   └── status.md           # Translation progress tracker
├── assets/                 # Book assets
│   ├── covers/             # Cover images (one per language)
│   ├── images/             # Interior illustrations
│   ├── styles/             # CSS for EPUB/HTML
│   └── templates/          # LaTeX/HTML templates
└── scripts/                # Helper scripts (optional)
```

## Quick Start

1. **Copy this scaffold** to create a new book:
   ```bash
   cp -r books/sample-book books/my-new-book
   ```

2. **Edit `config.yml`** with your book's metadata and structure

3. **Write content** in the `en/` directory (or your primary language)

4. **Add translations** in respective language directories

5. **Tag a release** to trigger the publishing workflow:
   ```bash
   git tag book-my-new-book-v1.0.0
   git push origin book-my-new-book-v1.0.0
   ```

## Configuration

The `config.yml` file controls:

- **Book metadata**: Title, author, version for each language
- **Structure**: Chapter order and organization
- **Languages**: Supported languages and their settings
- **Outputs**: Which formats to generate (EPUB, PDF, HTML)
- **Translation**: Translation memory and glossary settings

## Translation Workflow

1. Write content in the primary language (`en/` by default)
2. Copy English files to target language directory (e.g., `es/`)
3. Translate content, keeping frontmatter intact
4. Update translation status in `translations/status.md`
5. The CI will validate translations on each push

## Cover Images

Place cover images in `assets/covers/`:
- `cover-en.png` - English cover
- `cover-es.png` - Spanish cover
- `cover-en-print.png` - English print-ready cover (higher res)

## Customizing Templates

- **EPUB styling**: Edit `assets/styles/epub.css`
- **PDF layout**: Edit `assets/templates/pdf-template.latex`
- **HTML layout**: Edit `assets/templates/html-template.html`

## Publishing

### GitHub Releases (EPUB, PDF, HTML)

The workflow `.github/workflows/publish-book.yml` will:

1. Trigger on tags matching `book-*-v*`
2. Parse `config.yml` for book configuration
3. Generate EPUB, PDF, and HTML for each enabled language
4. Create a GitHub release with all formats
5. Upload artifacts for review

### GitHub Pages (Web Reader)

The workflow `.github/workflows/publish-book-to-pages.yml` publishes an online book reader:

**Published URL**: `https://[username].github.io/wombat-saga/books/sample-book/`

Features:
- Beautiful web reader interface
- Multi-language switching
- Chapter navigation (arrow keys work!)
- Mobile-responsive design
- Dark mode support

**To publish**:
```bash
# Push to main (auto-deploys)
git push origin main

# Or tag a release
git tag book-sample-book-v1.0.0
git push origin book-sample-book-v1.0.0
```

### Local Preview

Preview the book locally before publishing:

```bash
cd books/sample-book

# Preview in default language (English)
./scripts/preview.sh

# Preview specific language
./scripts/preview.sh es    # Spanish
./scripts/preview.sh fr    # French
./scripts/preview.sh de    # German
```

Opens the book in your default browser with navigation.

## Translation Status Tracking

See `translations/status.md` for current translation progress and review status of each language.
