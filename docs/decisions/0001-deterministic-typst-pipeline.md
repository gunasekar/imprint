# 0001 — Deterministic Typst pipeline

- Status: Accepted
- Date: 2026-06-21

## Context

imprint converts Markdown to PDF. The defining requirement is **determinism**: the
same Markdown must produce the same PDF on any machine, today or in a year — so
the output can be checked into version control and trusted for specs, runbooks,
and records.

## Decision

The render path is a fixed, offline pipeline:
`preprocess (python3) → pandoc → typst compile`. Typst is the typesetting engine
(a single static binary), and all fonts are **vendored** in `assets/fonts/` and
loaded via `--font-path`, never from the system.

## Consequences

- Output depends only on the input and the bundled fonts — reproducible anywhere
  the toolchain is installed.
- No runtime services, no headless browser for typesetting (only `mmdc` for
  Mermaid, which produces an intermediate SVG that is itself deterministic).
- The layout lives in one Typst template rather than CSS + a browser, so the
  theme is a single declarative artifact.
- Trade-off: contributors must learn a little Typst to change layout. Worth it
  for the reproducibility guarantee.
