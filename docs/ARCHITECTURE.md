# Architecture

How imprint turns a Markdown file into a PDF, and why it's built this way.

## The pipeline

imprint is one bash script (`imprint`) wrapping a four-stage pipeline. Every stage
is deterministic — given the same input and the same bundled fonts, the output
is byte-identical.

```
config.yaml ─┐
             ├─► [1] preprocess (python3) ─► processed.md + meta.kv
INPUT.md ────┘                                      │
                                                    ▼
                              [2] pandoc  ─► doc.typ (Typst source)
                                                    │
                                                    ▼
                              [3] typst compile ─► out.pdf
                                                    │
                                                    ▼
                                            [4] copy to OUT.pdf
```

### 1. Preprocess (inline python3, no pip deps)

A single `python3` heredoc inside `imprint` does all source-level work on a
throwaway build copy — the original `.md` is never touched:

- **Config + front matter merge.** Reads the config file (flat `key: value`) for
  **house-style settings** — the keys in `PDF_CONFIG_KEYS` (accent, fonts, the
  logo, and cover/confidential defaults). The document's front matter layers on
  top and is the sole source of document metadata (title, author, footer text, …).
  Both are parsed by the same tiny flat-key parser — no PyYAML. The config file is
  chosen by the bash wrapper before this step, which supports per-house-style
  **profiles** (`--profile NAME` / `IMPRINT_PROFILE` → `profiles/NAME.yaml`); see
  [ADR 0006](decisions/0006-org-profiles.md). Logo paths resolve by origin here —
  relative to the `.md` for front matter, relative to the config/profile file for
  config (see [ADR 0005](decisions/0005-logo-as-house-style.md)).
- **Title resolution.** `title` from front matter wins over the first `# H1`;
  the H1 is stripped from the body (unless `--keep-h1`) so it doesn't duplicate
  the header/cover.
- **Local images.** Copied into the build dir and their links rewritten, so Typst
  can resolve them under `--root`. Remote URLs are left alone. (Logo paths are
  resolved to absolute here by origin; the bash wrapper then applies any CLI
  override and copies the asset in.)
- **Mermaid → SVG.** Each ` ```mermaid ` block is rendered by `mmdc` to a vector
  SVG and replaced with a Typst `#figure`. A `%% caption:` line becomes the
  caption. `htmlLabels:false` makes Mermaid emit native `<text>` the Typst SVG
  renderer can actually draw.
- **Page breaks.** `<!-- pagebreak -->` becomes a Typst `#pagebreak(weak: true)`.

The merged metadata is written to `meta.kv`; the bash side then applies CLI
overrides and built-in defaults on top (final precedence:
**CLI > front matter > config > default**) and turns each value into a pandoc
`-V`/`-M` variable.

### 2. pandoc → Typst

`pandoc -t typst --template templates/default.typ` converts the processed
Markdown to Typst source. `--columns=1` forces pandoc to emit explicit table
column widths from the dash ratios; `--wrap=none` stops it from hard-wrapping the
generated Typst (which would corrupt code blocks).

### 3. typst compile

`typst compile … --root BUILD --font-path assets/fonts --ignore-system-fonts`
typesets the PDF. `--ignore-system-fonts` means only the bundled `assets/fonts/`
are used — never the machine's installed fonts — so the same input produces
identical output anywhere, and a stray system font can never shadow a bundled one.

### 4. Output

The finished PDF is copied to the requested path (default `INPUT.pdf`). The build
dir is a `mktemp -d` cleaned up on exit.

## The template

`templates/default.typ` is the single source of layout truth. It is a pandoc
Typst template — `$if(...)$ / $for(...)$` placeholders are filled by pandoc, then
the rest is plain Typst. Structure:

- **Theme tokens** at the top. The accent is one configurable color; `accent-dark`,
  `accent-soft`, and `accent-bright` are *derived* from it via `.darken()` /
  `.lighten()`, so changing `accent` re-tints headings, links, section dividers,
  table headers, callouts, and the gradient cover together. Grays (graphite ink,
  muted, hairline, surface) are fixed.
- **`conf(...)`** — a function holding every `show`/`set` rule (headings, code,
  callouts, tables, figures), the optional cover page, and the running
  header/footer. The body is passed in as `doc`. The cover has two styles sharing
  one `coverBody` closure: the default light page and an opt-in gradient wash
  (`cover_style: gradient`) — a dark slate anchor flowing into `accent`, echoing
  proof — see [ADR 0004](decisions/0004-optional-gradient-cover.md). With no
  cover, the first body page opens with a **masthead** (title, subtitle,
  description) and the running header begins on page 2.
- **`#show: doc => conf(...)`** wires the pandoc-filled metadata into `conf` and
  renders `$body$`.

### Design tokens

| Token | Value | Role |
|--------|--------|------|
| `accent` | `#2563EB` (config) | headings, links, section divider, table header tint, callout bar |
| `accent-dark` | `accent.darken(22%)` | links, eyebrow labels, bold lead-ins |
| `accent-soft` | `accent.lighten(90%)` | callout / table-head fill |
| `accent-bright` | `accent.lighten(28%)` | lifted-accent highlights (subtitle, labels) on the gradient cover |
| `cover-grad` | `#0F172A` (slate) → `accent` | gradient cover wash (opt-in); slate anchor keeps it dark so accent highlights read |
| `heading-ink` | `#111827` | table-head text, light-cover title |
| `ink` | `#1F2937` | body text |
| `muted` | `#6B7280` | captions, footer, labels |
| `hairline` | `#E5E7EB` | rules, borders, frames |
| `surface` | `#F9FAFB` | code blocks, table head base |

Fonts: Source Sans 3 (default) or IBM Plex Sans for body + headings, JetBrains
Mono for code — all bundled. The family names are config variables, so switching
between the bundled families (or dropping a different TTF into `assets/fonts/` and
naming it in config) changes the typeface.

## Why Typst

Typst is a single static binary with a real layout language (functions, derived
values, `show` rules), so the whole theme is one declarative template rather than
a pile of CSS plus a headless browser. It's fast, has no runtime dependencies,
and produces reproducible output — which is the entire point of imprint.

## Repo layout

```
imprint                     # the bash driver (the whole CLI)
templates/default.typ     # the one layout template
assets/fonts/             # bundled TTFs, embedded by Typst
config.example.yaml       # committed placeholder config
config.yaml               # your personal config (gitignored)
commands/imprint.md         # optional Claude Code /imprint slash command
examples/sample.md        # the bundled demo document
docs/                     # this file + decision records
```
