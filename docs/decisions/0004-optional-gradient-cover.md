# 0004 — Optional gradient cover, derived from the accent

- Status: Accepted
- Date: 2026-06-21

## Context

[ADR 0003](0003-cover-optional-and-default-theme.md) made the cover optional and,
when present, a calm light page — deliberately *not* a gradient, to keep the
default neutral. The parent tool (`proof`) ships a striking full-bleed gradient
cover, and some documents (proposals, external-facing reports) want that bolder
first impression. The ask: offer the gradient as an opt-in without compromising
the neutral default or imprint's single-accent, config-driven model.

`proof`'s gradient is hardcoded to its brand palette (slate → teal → green) and
carries a light/dark logo pair. imprint has no brand: it has one configurable
`accent` and the promise that changing it re-tints the whole document.

## Decision

1. **Gradient is an opt-in cover *style*, not a new cover.** `cover` still decides
   whether a title page renders; a new `cover_style` (`light` | `gradient`,
   default `light`) decides its look. The layout is shared — a single `coverBody`
   closure in the template — so the two styles differ only in fills and logo.
2. **The gradient mirrors proof's, tinted by `accent`.** A 45° linear wash from a
   dark slate anchor (`#0F172A`, proof's `cover-top`) at 0% → `accent.darken(22%)`
   at 60% → `accent` at 100%, with two soft radial glows from `accent.lighten(30%)`.
   The slate anchor is the one fixed color: it keeps the cover dark enough that a
   *lifted* accent (`accent.lighten(28%)`) reads as a highlight on the subtitle,
   eyebrow, and "Prepared" labels — exactly how proof uses its brand-light green.
   Title and recipient/author values stay white. Everything but the slate anchor
   derives from `accent`, so re-tinting the theme re-tints the wash and its
   highlights together.

   An earlier attempt derived the gradient *entirely* from `accent`
   (`accent.darken(62%)` → `accent`). On a single-accent (blue) wash that made the
   background the same hue as any accent-colored highlight, so the subtitle and
   logo washed out and had to fall back to plain white. proof avoids this with a
   dark, hue-neutral slate base; adopting the slate anchor is what lets imprint
   use a colored highlight the way proof does.
3. **A separate `logo_dark_bg` for the dark cover.** The normal (dark) `logo`
   would vanish on the wash. The gradient cover uses `logo_dark_bg` (a logo for a
   dark background — named after proof's `lockup-dark-bg`) when set and otherwise
   shows no cover logo; body-page running headers always use the normal `logo`.
4. **Selecting gradient implies the cover is on.** A gradient is meaningless
   without a cover, so the `--gradient` shorthand turns the cover on, and a
   per-document `cover_style: gradient` (front matter) does too — overriding a
   config default of `cover: false`. This implication lives in the python
   preprocessor, the one place that can tell a per-document setting from a config
   default. A document can still set `cover: false` to opt out, and the verbose
   `--cover-style gradient` only sets the look (pair it with `--cover`).

## Consequences

- The neutral default is untouched: no flags still yields a cover-less doc, and
  `--cover` still yields the light cover. The light cover's output is byte-for-byte
  identical after the `coverBody` refactor.
- One config token (`accent`) drives both the theme and the gradient, so there is
  nothing extra to keep in sync when re-skinning.
- `logo_dark_bg` adds a little surface, but it is the honest fix for contrast on a
  dark cover; without it the gradient cover simply omits the logo rather than
  rendering an invisible one.
- The cover-on implication is intentionally asymmetric (per-document settings
  trigger it, config defaults do not). This keeps `cover_style: gradient` as a
  house-style default from silently forcing covers onto every document.
