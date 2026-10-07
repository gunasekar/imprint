# 0010 — Canonical metadata keys match Quarto's

- Status: Accepted
- Date: 2026-07-14

## Context

Once front matter became standard YAML ([ADR 0009](0009-yaml-front-matter.md)) and the
template was shared with a Quarto format ([ADR 0008](0008-quarto-format-extension.md)),
one goal came into reach: **a single front-matter block that renders in both the CLI
and Quarto**. Two keys stood in the way.

imprint originally named them the obvious way — `logo` and `date`. Those are exactly
the two names Quarto *reserves and transforms*: Quarto coerces `logo` to a boolean, and
parses `date` into a real date (reformatting free text, and rendering the unparseable as
the literal words "Invalid Date"). So a file that used imprint's names could not be fed
to Quarto, and the two tools spoke different vocabularies for the same fields.

Every other imprint key is safe, because Quarto forwards keys it does not recognize
straight to the template. The collision was confined to these two reserved names.

## Decision

Make imprint's **canonical** keys the Quarto-safe names:

| Field | Canonical key | Alias (still accepted) |
|---|---|---|
| Header/cover logo | `headerlogo` | `logo` |
| Document date | `docdate` | `date` |

The alias folds into the canonical key in the preprocessor, before path resolution or
emission, so both spellings produce byte-identical output. `logo`/`date` are not
removed: `date` is the standard Markdown key, and no existing document should break.
The CLI flags stay `--logo` and `--date` — a flag has no YAML namespace to collide
with, and the short names are what a user reaches for.

Author needs no rename. It was already reconciled: imprint joins a YAML list
(`author: [A, B]` → `A, B`) and the shared template renders both pandoc's flat `author`
and Quarto's structured `by-author` the same way. Verified: a list author renders
identically through both tools.

## Consequences

- One front-matter block renders in both tools. Verified: the same file, logo in a
  subfolder, produced matching covers from the CLI and from Quarto.
- No document breaks — `logo` and `date` still work, silently, as aliases. CI keeps a
  fixture on each spelling (`ci-fixture.md` uses `date`; `quarto-fixture.qmd` uses
  `docdate`) so both paths stay covered.
- The output is unchanged: `docdate` and `date` fill the same template slot, as do
  `headerlogo` and `logo`, so every existing render is byte-for-byte identical.

## The tradeoff, stated plainly

`date` is the *industry-standard* front-matter key; `docdate` exists only to dodge
Quarto's coercion. Promoting `docdate` to canonical means imprint's documented key for a
date is non-standard — which sits in mild tension with "follow standards, avoid custom
keys."

It is accepted because the alternative is worse: keeping `date` canonical makes the
flagship goal — one portable file — impossible, since `date` is precisely the key Quarto
breaks. Keeping `date` as a working alias preserves the standard spelling for
CLI-only users who want it, so nothing is truly lost; only the *recommended* key
changes. `logo` → `headerlogo` carries no such tension: `logo` was never a standard,
just imprint's own name, so aligning it with Quarto costs nothing.
