# The Wombat Worlds Saga (The Broadcast)

**Domain:** The Narrative Simulation (Satire)

This directory contains **The Wombat Worlds Saga** (formerly MahaWombaratha). This is the story, the simulation, and the satire projected by the Oracle (`kintsugi-3/`) to explain the complexities of the physical world through the lens of Melborow.

> **"The Wombat Worlds is told by the Oracle to us through Hoebat."**

---

## 📂 Structural Mapping

### 1. **Core Narrative (`/stories`)**
*The linear progression of the saga, told through episodes and character arcs.*
*   `the_morning_glory_v4.md` — The establishing tone piece (Cooroo's awakening).
*   `the_council_fractures.md` — The political breakdown of the 5 Sovereigns.
*   `cooroos_warning.md` — The prophetic warning of the coming collapse.
*   `the_kappa_mu_assembly.md` — The formation of the protagonist team.

### 2. **World Building (`/lore` & `/constants`)**
*The physics, sociology, and metaphysics of Melborow.*
*   `lore.md` — The primary bible of the setting (The 5 Sovereigns, The Static, The Tall-Ones).
*   `meta_narrative.md` — The thematic underpinnings (Safety vs. Life, The Jacaranda Promise).
*   `constants/` — Specific laws of the universe.
    *   `arnam.md` — The concept of "Arnam" (Flow/Currency/Life-Force).
    *   `animal_societies.md` — The cultural norms of each species.
    *   `the_instincts.md` — The specific powers (Instincts) associated with each faction.

### 3. **Character Roster (`/characters`)**
*Detailed dossiers on the cast.*
*   `protagonists.md` — The Kappa Mu 5 (Hoebat, Merl, Pokero, Bash, Cooroo).
*   `antagonists.md` — The 5 Sovereign Wombats (Trumbat, Muskbat, Tatebat, Vitabat, Zuckbat).
*   `old_friends.md` — The civilians caught in the middle (Duzbat, Flickboo).
*   `hoebat/`, `merl/`, `cooroo/` — Deep-dive sub-directories for key characters.

### 4. **Orchestration & Tone (`/orchestration_prompts.md` & `/exploratory`)**
*The tools for generating the story.*
*   `orchestration_prompts.md` — Visual descriptions for image generation.
*   `exploratory/` — Drafting area for new narrative threads.
    *   `author_tone_guide.md` — **The 80/20 Weaver Guide** (Rowling/Asimov tone manual).
    *   `hoebat_journey_start.md` — Draft: Hoebat finding the root.
    *   `cooroo_journey_start.md` — Draft: Cooroo hearing the flower.
    *   `cornelibat_bedtime_start.md` — Draft: Cornelibat's backstory.
    *   `migopus_disappearance.md` — Draft: The forensic thriller of the Platypus.

### 5. **The Soundtrack (`/songs`)**
*The encrypted culture of the Rebellion.*
*   `majestic_arnem.md` — The Trap/Mumble Rap anthem containing the map to the water.
*   `melborow_frequency.md` — The Sovereign broadcast.
*   `the_jacaranda_prophecy.md` — The hymn of the return.

---

## 🔑 Key Documents
*   **[The Meta-Narrative](meta_narrative.md):** Read this first to understand the *Theme* (Servicing the Land vs. Owning the Land).
*   **[Lore Bible](lore.md):** Read this to understand the *Setting* (The Great Calcification).
*   **[Tone Guide](exploratory/author_tone_guide.md):** Read this to understand the *Voice* (80% Rowling / 20% Asimov).

---

## 🔗 Connection to The Oracle
This entire saga is a projection from the `kintsugi-3/` directory.
*   **The Sutras** provide the logic.
*   **Hoebat** enacts the logic.
*   **The Reader** (you) is the target of the logic.

---

## 🛠️ Build System & Development

This project includes a comprehensive build system for generating e-books (EPUB, PDF), a web-viewable book site, and a static site structure for the documentation.

### Prerequisites
*   **Pandoc**: Universal document converter (required for all builds).
*   **yq**: Command-line YAML processor (required for parsing configs).
*   **XeLaTeX**: Required for PDF generation (optional, only for PDF builds).

### Quick Start (Makefile)
The project includes a `Makefile` for common tasks:

```bash
make help        # Show available commands
make check       # Run CI checks (markdown linting, word counts)
make site        # Build the static site structure in 'site/'
make book        # Build book artifacts (EPUB, PDF, HTML)
make book-site   # Build the web-viewable book in '_site/'
make clean       # Clean up build artifacts
```

### Scripts
Standalone bash scripts are located in `scripts/`:
*   `scripts/build_book.sh`: Generates EPUB, PDF, and standalone HTML files.
*   `scripts/build_book_site.sh`: Generates a static HTML site for the book with chapter navigation.
*   `scripts/build_site.sh`: Aggregates all markdown content for a static site generator (e.g., mdBook, Jekyll).
*   `scripts/run_checks.sh`: Runs linting and statistics.

### GitHub Actions
The project is configured with GitHub Actions in `.github/workflows/`:
*   `ci.yml`: Runs on push/PR to validate markdown and check links.
*   `publish-book.yml`: Triggered by tags (`book-*-v*`) to build and release e-books.
*   `publish-book-to-pages.yml`: Deploys the web-viewable book to GitHub Pages.
*   `publish-site.yml`: Deploys the documentation site to GitHub Pages.