# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [2026-07-04] — Migrate to Quarto

Rebuilt the blog on the [Quarto](https://quarto.org) framework, replacing the
previous bespoke Python + KaTeX static-site generator.

### Added
- Quarto project (`_quarto.yml`) with `.qmd` sources; renders to `docs/` for
  GitHub Pages (`master` `/docs`).
- "Classic academic" theme (`theme.scss`): EB Garamond serif, parchment palette,
  oxblood navbar.
- Automatic equation numbering for every display equation (MathJax `tags: 'all'`),
  with `\eqref` equation references and `@fig-`/`@sec-` cross-references.
- Home listing, Machine Learning / Other Topics category pages, About, References.
- giscus comments (GitHub Discussions), configured in `posts/_metadata.yml`
  (`repo-id` / `category-id` still to be filled from <https://giscus.app>).
- **Per-post PDF download** ("Other Formats → PDF"): a PDF-only Pandoc Lua filter
  (`_filters/pdf-equations.lua`) wraps display math in numbered `equation`
  environments, unwraps `\eqref`, and swaps animated GIFs for static stills; the
  HTML output is left untouched. Requires TinyTeX.
- CI workflow (`.github/workflows/verify-outputs.yml`) that re-renders and fails
  if the committed `docs/` is out of sync with the sources — byte-diff for HTML
  (excluding the build-stamped `sitemap.xml`), `pdftotext` text-diff for PDFs.
- `README.md` with build, PDF, and deployment instructions; this changelog.

### Changed
- Post sources migrated from LaTeX/HTML to `.qmd` (`batch_size_vs_momentum`,
  `pearcey_basis`); article prose left unchanged. Manual equation numbers and
  anchor cross-references replaced by automatic numbering/cross-refs.

### Removed
- The borrowed jaan.io stylesheet (`css/`) and legacy inline-Disqus / TOC scripts
  (`js/`).
- Hand-maintained top-level HTML pages, superseded by generated output.
