# GitHub Actions Workflows

This directory contains the CI/CD pipelines for the Wombat Worlds Saga project.

## Workflows

### 1. CI (`ci.yml`)

Runs on every push to validate the content:

- **Validate Markdown**: Checks formatting with markdownlint
- **Check Links**: Validates internal and external links using lychee
- **Generate Stats**: Counts words by category and uploads statistics

### 2. Publish Site (`publish-site.yml`)

Builds and deploys a static site to GitHub Pages:

- Aggregates all markdown content into a Jekyll site
- Deploys to `https://[username].github.io/wombat/`
- Runs automatically on changes to `wombat-saga/`

**To enable**: Go to Settings → Pages → Source → GitHub Actions

### 3. Release (`release.yml`)

Builds e-books and creates releases:

- **EPUB**: For e-readers (Kindle, Apple Books, etc.)
- **PDF**: Print-ready document
- **Wattpad TXT**: Plain text compilation for Wattpad uploading

Triggered by:
- Pushing a tag: `git tag v1.0.0 && git push origin v1.0.0`
- Manual dispatch from Actions tab

### 4. Publish Book (`publish-book.yml`) - Multi-Language Support

Builds and publishes multi-language books from the `books/` directory:

- **Multi-format**: EPUB, PDF, HTML
- **Multi-language**: Builds for all configured languages
- **Translation-aware**: Reads configuration from `config.yml`
- **Automated releases**: Creates GitHub releases with all formats

**Usage:**

```bash
# Tag a book for release (format: book-{id}-v{version})
git tag book-sample-book-v1.0.0
git push origin book-sample-book-v1.0.0

# The workflow will:
# 1. Parse books/sample-book/config.yml
# 2. Build EPUB/PDF/HTML for each language
# 3. Create a GitHub release with all files
```

**Manual dispatch**: Go to Actions → Publish Book → Run workflow

## Usage

### Creating a Release

```bash
# Tag a new version
git tag v1.0.0

# Push the tag
git push origin v1.0.0

# The workflow will automatically create a release with e-books attached
```

### Publishing a Multi-Language Book

1. Create a new book from the sample scaffold:
   ```bash
   cp -r books/sample-book books/my-new-book
   ```

2. Edit `books/my-new-book/config.yml` with your book's metadata

3. Write content in the primary language directory (e.g., `en/`)

4. Add translations in other language directories

5. Tag and release:
   ```bash
   git tag book-my-new-book-v1.0.0
   git push origin book-my-new-book-v1.0.0
   ```

### Viewing Stats

After each CI run, word count statistics are available as artifacts:
1. Go to Actions → CI → Latest run
2. Download "word-count-stats" artifact

### Local Testing

Install the same tools locally:

```bash
# Markdown linting
npm install -g markdownlint-cli
markdownlint wombat-saga/**/*.md

# Link checking
cargo install lychee
lychee wombat-saga/**/*.md

# E-book generation
pandoc --from markdown --to epub -o book.epub wombat-saga/meta_narrative.md

# Multi-language book building
cd books/sample-book
pandoc --from markdown --to epub -o sample-book-en.epub en/*.md
```

## Multi-Language Book Structure

```
books/{book-id}/
├── config.yml              # Main configuration
├── en/                     # Primary language content
│   ├── 00-cover.md
│   ├── 00-title.md
│   ├── 01-chapter.md
│   └── ...
├── es/                     # Spanish translation
├── fr/                     # French translation
├── translations/           # Translation management
│   ├── glossary/           # Translation glossaries
│   └── status.md           # Progress tracking
└── assets/                 # Book assets
    ├── covers/             # Cover images (per language)
    ├── styles/             # CSS for EPUB
    └── templates/          # PDF/HTML templates
```

See `books/sample-book/README.md` for detailed documentation.
