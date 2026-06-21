# 0005 — Logo is house style (a config default)

- Status: Accepted
- Date: 2026-06-21
- Amends: [0002](0002-render-config-vs-document-metadata.md)

## Context

[ADR 0002](0002-render-config-vs-document-metadata.md) split settings into
*rendering config* (reusable house style) and *document metadata* (per-file), and
placed `logo` with the document metadata. Its own History notes why: an early
draft had lumped `logo` together with `author` and `footer_text` in config, which
made a supposedly-shareable config carry one person's name — so all three were
moved out to front matter.

But `logo` is not like `author`/`footer_text`. A byline and footer name are
genuinely per-document identity; a **logo is branding that is identical on every
document** — exactly like `accent` and the fonts. By the test ADR 0002 actually
uses everywhere else ("is this reusable across documents?"), `logo` belongs with
house style, not with document metadata. The parent tool agrees implicitly:
`proof` *defaults* its logo to a bundled brand asset, treating it as house style
with a per-document override. Requiring `logo:` in every document's front matter
is boilerplate that contradicts imprint's "set your house style once" ergonomics.

## Decision

Promote `logo`, `logo_dark_bg`, and `logo_height` to **house-style keys** in
`PDF_CONFIG_KEYS`, so a config file can set them as a default, while front matter
(or `--logo`) still overrides per document. Precedence is unchanged: **CLI >
front matter > config > default**.

Resolve logo paths **by origin**, in the preprocessor where the origin is known:

- a **config** `logo` path is resolved relative to the **config file** (the logo
  lives centrally, next to the config — not beside each document);
- a **front-matter** `logo` path is resolved relative to the **`.md`** (as before);
- absolute paths are taken as-is.

Add the escape hatches a config default needs: `logo: none` in a document drops
an inherited config logo, and `--no-logo` drops it for one run.

## Consequences

- The common case — *my logo on every document* — is now a set-once config value,
  consistent with `accent` and fonts. Per-document and co-branded logos still work
  via front matter / `--logo`.
- The "config carries no identity at all" purity of ADR 0002 is relaxed: a logo is
  branding. This is low-risk in practice — the real `config.yaml` is gitignored;
  only `config.example.yaml` (with the logo commented out) is committed.
- Path resolution gains one rule (config-relative vs `.md`-relative). It is
  resolved in Python, the only place that can distinguish a config-origin value
  from a front-matter one — the same reason the gradient cover-on implication
  lives there ([ADR 0004](0004-optional-gradient-cover.md)).
- `author` and `footer_text` stay in front matter: those *are* per-document
  identity, so ADR 0002's split holds for everything except the logo.
