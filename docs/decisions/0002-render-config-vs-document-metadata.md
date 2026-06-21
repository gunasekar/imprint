# 0002 — Rendering config vs document metadata

- Status: Accepted
- Date: 2026-06-21

## Context

imprint is derived from an internal, single-brand tool whose name, colors, logo,
and footer text were hardcoded into the Typst template. imprint is meant to be a
**personal, open-source** tool: the repo must be safe to publish, and the tool
must be reusable across many documents and many authors.

Two kinds of settings were getting conflated: *how* a PDF is rendered (the
theme, the fonts, whether a cover shows) versus *what* a particular document is
(its title, author, footer text, logo). The first is a stable house style; the
second changes with every file.

## Decision

Split them by where they live:

- **Rendering config** lives in a `config.yaml`, resolved at `$IMPRINT_CONFIG` →
  `~/.config/imprint/config.yaml` → `./config.yaml`. It holds *only* render-level
  keys (`PDF_CONFIG_KEYS`): the theme `accent`, the `font_*` families, and the
  default `cover` / `confidential` toggles. It is a reusable house style.
- **Document metadata** (title, author, footer text, logo, recipient, date,
  category) lives in each document's **front matter**, or a CLI flag. It is never
  read from config.

Precedence for any value: **CLI flag > document front matter > config (render
keys only) > built-in default**. Unset optionals are omitted, never invented.

## Consequences

- The config carries no document content and no personal data — so the repo is
  public by design, and a shared config is just a theme, not someone's identity.
- A document is self-describing: everything that appears in *that* PDF (its title,
  byline, logo) is in the `.md` itself, which also reads well on GitHub.
- A user with no config still gets a clean, neutral document (default blue accent,
  empty footer text).
- Re-theming is mostly one value: `accent` is a single color from which light and
  dark shades are derived.
- Bundled fonts are limited to openly licensed faces so redistribution is
  unencumbered.

## History

The first draft (titled "Config-driven identity") put author, footer text, and
logo in config alongside the theme. That conflated reusable render settings with
per-document metadata — a config that was meant to be shareable ended up carrying
one person's name. The decision was corrected, before any release, to the split
above: config is rendering only; identity is per document.
