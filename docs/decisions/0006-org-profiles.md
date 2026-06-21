# 0006 — Per-house-style profiles (`--profile`)

- Status: Accepted
- Date: 2026-06-21
- Builds on: [0002](0002-render-config-vs-document-metadata.md), [0005](0005-logo-as-house-style.md)

## Context

[ADR 0002](0002-render-config-vs-document-metadata.md) made the config file a
reusable house style, and [ADR 0005](0005-logo-as-house-style.md) added the logo
to it. But a user who renders for **several orgs** (or brands, or clients) has
several house styles — each its own accent, fonts, and logo — and only one
config slot. Today they would juggle `IMPRINT_CONFIG` paths or shell aliases by
hand. We want switching house styles to be a first-class, discoverable action.

## Decision

Support named **profiles** — one config file per house style — under
`~/.config/imprint/profiles/<name>.yaml`, selected per render:

- `--profile NAME` picks `profiles/NAME.yaml` for this run.
- `IMPRINT_PROFILE=NAME` sets a default profile for a shell.
- `--list-profiles` prints the available profiles.
- `make profile NAME=acme` scaffolds one from `config.example.yaml`.

A profile *is* a config file — same keys, same parser, nothing new to learn. It
slots into the existing config lookup, which becomes (first found wins):

```
--profile  >  $IMPRINT_CONFIG  >  IMPRINT_PROFILE  >  ~/.config/imprint/config.yaml  >  ./config.yaml
```

A named-but-missing profile is a hard error (exit 2), not a silent fall-through —
rendering with the wrong or default branding is worse than failing.

## Consequences

- Multi-org becomes one flag: `imprint report.md --profile acme`. Per-document
  front matter and CLI flags still override the profile, so a one-off can re-tint
  without editing it.
- It composes for free with [ADR 0005](0005-logo-as-house-style.md): a config
  logo resolves relative to its file, so each profile keeps its own logo (and
  `logo_dark_bg`) beside it in `profiles/`. No per-profile path juggling.
- A profile can also use a brand typeface: imprint adds `~/.config/imprint/fonts/`
  to Typst's `--font-path` (alongside the bundled fonts), so dropping a face there
  and naming it in `font_*` is enough — `--ignore-system-fonts` still holds, so the
  render stays deterministic given the bundled + user font dirs.
- Named "profile", not "org". A profile is a *named bundle of house style* — the
  conventional term (cf. `aws --profile`) and general enough for brands, clients,
  or internal-vs-external, not only organizations. It also matches the `profiles/`
  directory, so flag, env var, and storage share one word.
- The selection lives in the bash wrapper (it picks the config file before the
  preprocessor runs); the rest of the pipeline is unchanged — a profile is just
  the config it resolves to.
