# alexeytochin.github.io

Personal blog on machine learning and mathematical physics, built with
[**Quarto**](https://quarto.org). Source is Markdown + LaTeX math (`.qmd`); the
rendered site is written to `docs/` and served by GitHub Pages.

Live site: <https://alexeytochin.github.io>

---

## Prerequisites

### 1. Quarto (required)

Install the Quarto CLI from <https://quarto.org/docs/get-started/>. Verify:

```bash
quarto --version
```

> On this machine Quarto is installed **user-local** (no sudo) at
> `~/.local/bin/quarto` → `~/opt/quarto-<version>/`.

### 2. TinyTeX (required only for PDF output)

Each article also offers a downloadable PDF, which is produced through LaTeX.
Install the LaTeX engine once with Quarto's bundled installer (no sudo needed):

```bash
quarto install tinytex
```

This installs a self-contained TeX distribution under `~/.TinyTeX/`. You only
need it if you want to build the PDFs; the HTML site builds without it.

---

## Building the site

```bash
# Render the whole site (all pages + posts, HTML and PDF) into docs/
quarto render

# Live preview with hot-reload while writing (HTML only — see PDF note below)
quarto preview
```

`quarto render` writes everything to `docs/`, including `docs/.nojekyll`. Commit
`docs/` — GitHub Pages serves it directly.

### Rendering a single post

```bash
# Rebuild one post in all its formats (HTML + PDF)
quarto render posts/is_batch_size_a_real_hyperparameter/index.qmd
```

---

## Generating / regenerating the PDF

Every post renders a PDF alongside its HTML; the download link appears in the
article's sidebar under **"Other Formats → PDF"**. The file lands at
`docs/posts/<slug>/index.pdf`.

```bash
# Rebuild BOTH formats for a post
quarto render posts/<slug>/index.qmd

# Faster — rebuild only the PDF after a text change
quarto render posts/<slug>/index.qmd --to pdf

# Rebuild every PDF on the site
quarto render
```

**Important:**

- **`quarto preview` does not build PDFs.** Preview is HTML-only. After editing,
  run `quarto render … --to pdf` explicitly to refresh the PDF.
- **Animated GIFs need a static still for the PDF** (LaTeX can't embed GIFs). For
  every `posts/<slug>/images/x.gif`, generate `x-still.png` once:
  ```bash
  cd posts/<slug>/images
  convert x.gif -coalesce -delete 0--2 x-still.png   # ImageMagick; grabs last frame
  ```
  A PDF-only filter (`_filters/pdf-equations.lua`) automatically swaps `x.gif` →
  `x-still.png` when building the PDF; the HTML keeps the animation.
- **Sanity check** a rebuilt PDF (should print `0` — no broken equation refs):
  ```bash
  pdftotext docs/posts/<slug>/index.pdf - | grep -c '??'
  ```

### How equation numbering works

The HTML numbers every display equation via MathJax (`tex.tags: 'all'`, set in
`_quarto.yml`) and references them with `$\eqref{...}$`. That trick is HTML-only,
so for the PDF a Pandoc **Lua filter** (`_filters/pdf-equations.lua`, run for
`latex` output only) wraps each display equation in a numbered `equation`
environment and unwraps the `\eqref` references. The `.qmd` sources and the HTML
output are never modified by this.

---

## Project structure

```
_quarto.yml          # site config: navbar, theme, MathJax, output-dir: docs, render list
theme.scss           # "classic academic" styling (cosmo + custom variables)
index.qmd            # home — listing of all posts
machine_learning.qmd # category listing (posts tagged machine-learning)
other_topics.qmd     # category listing (posts tagged other-topics)
about.qmd
references.qmd
posts/
  _metadata.yml      # shared post config: formats (html + pdf), author, giscus comments
  <slug>/
    index.qmd        # the article
    images/          # figures (PNG/GIF) + <name>-still.png for any GIF
_filters/
  pdf-equations.lua  # PDF-only: numbered equations, \eqref, GIF→still
docs/                # rendered output (committed; served by GitHub Pages)
```

## Adding a new post

1. Create `posts/<slug>/index.qmd` with front matter:
   ```yaml
   ---
   title: "..."
   description: "..."               # also used as the listing summary
   date: "YYYY-MM-DD"
   categories: [machine-learning]   # or [other-topics] — selects the listing page
   image: images/icon.png           # listing thumbnail
   ---
   ```
2. Put figures in `posts/<slug>/images/`; for any GIF also create a `-still.png`.
3. Write body in Markdown. Math conventions:
   - Inline: `$...$`. Display: `$$ ... $$` (auto-numbered).
   - To reference an equation: put `\label{eq:slug}` inside the `$$`, cite it as
     `$\eqref{eq:slug}$`.
   - Figures `![Cap](images/f.png){#fig-slug}` → reference `@fig-slug`;
     sections `## Title {#sec-slug}` → reference `@sec-slug`.
   - Use math-mode-valid macros (e.g. `\dagger`, not `\dag`).
4. `quarto render posts/<slug>/index.qmd` to build HTML + PDF.

Drafts: set `draft: true` **and** add `- "!posts/<slug>/**"` under
`project.render` in `_quarto.yml` (otherwise Quarto still emits the draft).

---

## Deployment

- Output goes to `docs/`; set **GitHub Pages source to the `master` branch,
  `/docs` folder** (repository *Settings → Pages*). `docs/.nojekyll` is created
  automatically so Pages serves the files as-is.
- Commit both the sources and the rendered `docs/`.

## Continuous integration

`.github/workflows/verify-outputs.yml` runs on pushes to `master`, on pull
requests, and on demand. It re-renders the site and **fails if the committed
`docs/` is out of sync with the `.qmd` sources**:

- HTML and assets are compared **byte-for-byte** (excluding the build-stamped
  `sitemap.xml`).
- PDFs are compared by **extracted text** (`pdftotext`), since PDFs embed a
  creation timestamp and are not byte-reproducible; it also flags any broken
  `??` cross-references.

If it fails, run `quarto render` locally and commit the updated `docs/`. The
workflow pins Quarto to the version used for the committed output — bump
`version:` in the workflow if you upgrade Quarto and re-render.

You can dry-run the same checks locally:

```bash
mv docs docs_committed && quarto render
diff -r -x sitemap.xml -x '*.pdf' docs_committed docs   # HTML: prints nothing if OK
# PDF text check: compare pdftotext of docs_committed/*.pdf vs docs/*.pdf
rm -rf docs_committed
```

## Comments (giscus)

Comments use [giscus](https://giscus.app) (GitHub Discussions), configured in
`posts/_metadata.yml`, which holds the repository and category ids (discussion
category "Comments", Announcement format). The giscus app is installed and Discussions are on. giscus
needs the repository to be **public**, and the site itself needs GitHub Pages
(`master`, `/docs`); until both hold, the comment box will not load for visitors.
