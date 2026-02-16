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

## Usage

### Creating a Release

```bash
# Tag a new version
git tag v1.0.0

# Push the tag
git push origin v1.0.0

# The workflow will automatically create a release with e-books attached
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
```
