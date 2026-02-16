# Books Directory

This directory contains published books from the Wombat Worlds Saga, organized for multi-language publishing.

## Directory Structure

```text
books/
├── README.md              # This file
├── sample-book/           # Example book with full scaffolding
│   ├── config.yml         # Book configuration
│   ├── en/                # English content
│   ├── es/                # Spanish translation
│   ├── fr/                # French translation
│   ├── de/                # German translation
│   ├── assets/            # Covers, styles, templates
│   └── translations/      # Glossary and status tracking
│
└── [your-book]/           # Future books follow same structure
    └── ...
```

## Creating a New Book

1. **Copy the sample scaffolding:**

   ```bash
   cp -r books/sample-book books/your-book-name
   ```

2. **Edit `config.yml`** with your book's metadata, structure, and languages

3. **Write content** in the primary language directory (e.g., `en/`)

4. **Add translations** in respective language directories

5. **Publish** by pushing a tag:

   ```bash
   git tag book-your-book-name-v1.0.0
   git push origin book-your-book-name-v1.0.0
   ```

## Configuration Reference

See `sample-book/config.yml` for a complete example. Key sections:

- `book`: Title, author, version for each language
- `languages`: Supported languages and their settings
- `structure`: Chapter organization
- `outputs`: Enabled formats (epub, pdf, html)
- `translation`: Glossary and translation memory settings

## Publishing Workflow

The `.github/workflows/publish-book.yml` workflow:

1. Triggers on tags matching `book-*-v*`
2. Reads configuration from `config.yml`
3. Builds EPUB, PDF, and HTML for each enabled language
4. Creates a GitHub release with all artifacts

## Translation Workflow

1. Complete content in primary language
2. Copy files to target language directory
3. Translate while preserving YAML frontmatter
4. Update `translations/status.md`
5. Commit and push changes

## Book Content Format

Each markdown file should include YAML frontmatter:

```yaml
---
id: chapter01
type: chapter
lang: en
part: 1
chapter: 1
title: "Chapter Title"
---
```

Valid `type` values: `cover`, `titlepage`, `toc`, `dedication`, `part`, `chapter`, `glossary`, `about`
