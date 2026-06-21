# 0003 — Cover optional, graphite + blue theme

- Status: Accepted
- Date: 2026-06-21

## Context

The parent tool always rendered a full-bleed branded cover and used a fixed brand
color. For a general-purpose Markdown → PDF tool, most documents (notes, specs,
runbooks) want to start straight into content, and the default look should read
as a neutral technical document rather than one organization's brand.

## Decision

1. **Cover page is optional and off by default.** Body pages render with a
   Titled running header (document title, right, over a thin rule) and a footer
   (name left, page number right). A title page renders only with `--cover` /
   `cover: true`, and is a calm light cover — not a gradient.
2. **Default theme is graphite + blue.** Graphite text (`#1F2937`) and headings
   (`#111827`) with a single technical blue accent (`#2563EB`) on links, H1
   underline rules, table headers, and callouts. The accent is config-overridable;
   the feel is a modern documentation site.

## Consequences

- The common case (a plain doc) needs zero flags and produces a clean,
  cover-less PDF.
- The header/footer were deliberately kept quiet (no logo, no organization
  string) to suit personal and open-source use; a logo appears only on the
  optional cover, only when configured.
- A single accent token keeps the theme cohesive and easy to re-skin. Additional
  named theme presets could be layered on later without changing this default.

## Update — 2026-06-21

The default accent was initially a teal (`#0D9488`). It was changed to a
technical blue (`#2563EB`) before the tool saw real use: teal reads as the same
green family as the parent tool, and a blue is the more conventional, neutral
choice for technical documentation. The accent remains a single config token, so
this was a one-value change.

Headings were also originally graphite (`#111827`); they were moved to the accent
to follow proof, which colors every heading in its brand. This keeps imprint's
look consistent with the parent tool and lets the one accent token drive headings
along with links, dividers, table heads, and callouts. Body text stays graphite;
table-head text and the light-cover title keep `heading-ink`.
