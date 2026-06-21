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
2. **The gradient is derived entirely from `accent`.** A 45° linear wash from
   `accent.darken(62%)` → `accent.darken(20%)` → `accent`, with two soft radial
   glows from `accent.lighten(20%)`. No new color tokens to configure: re-tinting
   `accent` re-tints the gradient too, keeping the single-accent promise.
3. **A separate `logo_white` for the dark cover.** The normal (dark) `logo` would
   vanish on the wash. The gradient cover uses `logo_white` when set and otherwise
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
- `logo_white` adds a little surface, but it is the honest fix for contrast on a
  dark cover; without it the gradient cover simply omits the logo rather than
  rendering an invisible one.
- The cover-on implication is intentionally asymmetric (per-document settings
  trigger it, config defaults do not). This keeps `cover_style: gradient` as a
  house-style default from silently forcing covers onto every document.
