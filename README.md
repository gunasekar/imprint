<!--
title: "imprint"
subtitle: "Branded, typeset documents from Markdown"
description: "Turn a Markdown file into a branded, typeset PDF — cover page, running header and footer, and a reusable house style — with one command."
category: "Documentation"
-->
# imprint

Turn Markdown into **branded, typeset PDFs** — the specs, design docs, and reports
that need to look official. One command gives you a title page, a running header
and footer, and a consistent house style, with your content flowed straight through.

What sets it apart:

- **Zero-config & lightweight** — `imprint report.md` just works. No LaTeX — just
  pandoc and Typst, both single static binaries. Every key is optional; the neutral
  defaults render fine on their own.
- **Reusable house styles** — set your brand once (accent, fonts, logo) and apply
  it to every document. **How** a PDF is rendered lives in a small config file;
  **what** a document says lives in its front matter. Keep one config per org as a
  **profile** and switch with `--profile`; each document overrides only what it needs.
- **Deterministic** — bundled, embedded fonts and a fixed pandoc → Typst pipeline
  (system fonts ignored) typeset the same input identically on any machine. The PDF
  timestamp follows the source file; set `SOURCE_DATE_EPOCH` for byte-identical
  output in CI.

In short: Quarto's set-brand-once model without Quarto's weight, and Eisvogel's
polish without LaTeX.

```bash
imprint report.md                      # -> report.pdf
imprint report.md --cover              # add a title page (off by default)
imprint report.md --accent "#2563EB"   # re-theme for one run
```

## What it looks like

Every image below renders the same [`examples/sample.md`](examples/sample.md) —
only the config and switches change.

**Set your brand once — a profile per org.** The accent color and logo live in a
config file; switch with `--profile`. Same document, three brands:

![The same document rendered as three org profiles — Acme (blue), Contoso (teal), and Fabrikam (maroon), each with its own accent color and logo](docs/images/showcase-profiles.png)

**The cover is optional.** Off by default, the first page opens with a masthead
(title, subtitle, description) and the running header begins on page 2; `--cover`
adds a calm, light title page, and `--gradient` swaps in a dark accent wash. A
light logo (`logo_dark_bg`) keeps the mark visible on that wash.

![Masthead by default, or a calm light title page with --cover](docs/images/showcase-covers.png)

**Markdown in, typeset PDF out.** Block quotes become callouts, tables span the full
page width, code is themed, and Mermaid blocks render to crisp vector figures.

![A body page with a callout, table, and code, beside a Mermaid diagram rendered as a framed figure](docs/images/showcase-interior.png)

## What you get

- **Clean body pages by default** — a Titled running header (an optional logo on
  the left, the document title on the right, over a thin rule) and a footer
  (optional footer text on the left, page number right). No cover unless you ask
  for one — instead the first page opens with a **masthead** (title, subtitle,
  description), and the running header begins on page 2.
- **Optional title page** — pass `--cover` (or `cover: true`) for a calm, light
  cover: title, subtitle, description, a `Prepared for / Prepared by` band, and
  an optional category eyebrow. Prefer something bolder? Add `--gradient` (or
  `cover_style: gradient`) alongside it to swap that cover for a dark accent wash
  with lifted-accent highlights — the style picks the look, `--cover` turns it on.
- **Optional TOC and section numbering** — both **off by default**, so output stays
  1:1 with your Markdown. Pass `--toc` (or `toc: true`) for a table of contents with
  page numbers; pass `--numbered` (or `numbered: true`) to number headings. Numbering
  is render-only — it never touches your heading text, just as the source `.md` is
  never modified.
- **Graphite + blue theme** — graphite body text, a single configurable accent (a
  professional technical blue by default) on headings, links, section dividers,
  table headers, and callouts. Change one value in config to re-tint the whole
  document.
- **Mermaid** ` ```mermaid ` blocks auto-rendered to crisp vector **SVG**,
  centered in a framed figure with an optional caption.
- **Callouts** — any Markdown block quote becomes a tinted note box.
- **Self-contained fonts** — Source Sans 3 (default) or IBM Plex Sans for
  body/headings, JetBrains Mono for code; all bundled and embedded, and rendering
  ignores system fonts, so output is identical on any machine. Need a brand
  typeface? Drop its TTFs in `~/.config/imprint/fonts/` and name the family in
  config — imprint searches that dir too.
- **Typeset with Typst** — a single static binary; deterministic and reproducible
  (pin `SOURCE_DATE_EPOCH` for byte-identical PDFs across machines and CI).

## Install

### One command

```bash
curl -fsSL https://raw.githubusercontent.com/gunasekar/imprint/main/install.sh | sh
```

Works on macOS and Linux. It clones imprint into `~/.local/share/imprint`, symlinks
the `imprint` command into `~/.local/bin`, scaffolds `~/.config/imprint/config.yaml`,
and checks your prerequisites (with OS-specific install hints for anything
missing). If Claude Code is detected (`~/.claude` exists), it also links the
optional [`/imprint`](skills/imprint/SKILL.md) skill (skip with
`IMPRINT_NO_CLAUDE_SKILL=1`). Re-run it anytime to update. Override locations with
`IMPRINT_HOME` / `IMPRINT_BIN`. It does **not** install the external tools below —
install those once with your package manager.

### Prerequisites

**macOS (Homebrew)**

```bash
brew install pandoc typst        # core
brew install mermaid-cli         # only if your docs use Mermaid (pulls in node)
```

**Linux**

```bash
# pandoc — any 3.0+ works, including current distro packages (e.g. Ubuntu 24.04's
# 3.1). Only older distros ship pandoc 2.x (no Typst writer) — for those, grab a
# 3.x .deb/.tar.gz from https://github.com/jgm/pandoc/releases
cargo install --locked typst-cli           # typst (or a build from its GitHub releases)
npm install -g @mermaid-js/mermaid-cli      # only if your docs use Mermaid
```

Typst is also packaged for several distros (Arch, openSUSE, …) — check
[Repology](https://repology.org/project/typst/versions). `python3` and `bash`
ship on virtually every Linux box.

**Windows (WSL2)**

imprint is a Bash CLI, so it doesn't run natively in PowerShell or cmd. Use
[WSL2](https://learn.microsoft.com/windows/wsl/install) and follow the **Linux**
steps above inside your WSL distribution — everything works unchanged.

| Tool | Needed for | Notes |
|------|------|----------|
| `pandoc` ≥ 3.0 | always | Markdown → Typst (writer added in 3.0; stock distro 3.x is fine) |
| `typst` | always | single static binary; typesets the PDF |
| `mmdc` | docs with Mermaid | uses headless Chromium under the hood |
| `python3`, `bash` | always | stdlib only, no pip packages |

### From a clone

If you'd rather clone it yourself:

```bash
git clone https://github.com/gunasekar/imprint && cd imprint
make install   # symlink ./imprint onto PATH, then report prerequisite status
make config    # copy config.example.yaml -> ~/.config/imprint/config.yaml
make example   # render examples/sample.md -> examples/sample.pdf
```

Then edit `~/.config/imprint/config.yaml` with your preferred accent color.

## Configure rendering (config)

The config file holds your **house style** — the theme (accent, fonts), your logo,
and the default toggles. It's reusable branding you apply to every document: set
your accent, fonts, and logo here once and every PDF matches. Anything you set is
just a default — a single document overrides it in its own front matter (and
`accent` / `cover` / `--logo` / `--no-logo` can also be set with a CLI flag for one
run). It's looked up in this order (first found wins):

1. `$IMPRINT_CONFIG` — an explicit path
2. `~/.config/imprint/config.yaml` — recommended for an installed imprint
3. `./config.yaml` — repo-local (gitignored), handy while developing

See [`config.example.yaml`](config.example.yaml) for every key. All keys are
optional — imprint renders fine with no config at all (you get the neutral
defaults).

```yaml
accent:     "#2563EB"          # the single theme color
font_body:  "Source Sans 3"    # body + heading font — "Source Sans 3" or "IBM Plex Sans"
font_mono:  "JetBrains Mono"   # code font
logo:       "logo.svg"         # your brand mark — resolved relative to this config file
cover:      false              # title page off by default
```

A config `logo` path is resolved relative to **the config file** (keep the asset
beside it, or use an absolute path). Document-specific metadata — title, author,
footer text, recipient, … — does **not** go here; it lives in each document's
front matter (next section), which is also where you override or drop the logo
for one document (`logo: none`).

### Multiple house styles (profiles)

Render for several orgs (or brands, or clients) by keeping one config per house
style — a **profile** — under `~/.config/imprint/profiles/`, and selecting it with
`--profile`:

```
~/.config/imprint/
  config.yaml                 # your personal default (no profile)
  profiles/
    acme.yaml                 # accent, fonts, logo for Acme
    acme.svg
    acme-dark.svg             # logo_dark_bg for Acme's gradient cover
    contoso.yaml
    contoso.svg
```

```bash
imprint report.md --profile acme      # Acme's accent + Acme logo
imprint report.md --profile contoso   # Contoso's accent + Contoso logo
make profile NAME=acme                # scaffold profiles/acme.yaml from the example
imprint --list-profiles               # show the profiles you have
```

A profile is just a config file, so it holds the same keys (`accent`, `font_*`,
`logo`, `logo_dark_bg`, default toggles) — and because a config `logo` resolves
next to its file, each profile keeps its logo beside it. A profile can also name a
custom `font_*` family; put the TTFs in `~/.config/imprint/fonts/` (searched for
every profile). Set a default profile for a shell with `export IMPRINT_PROFILE=acme`;
a document's front matter and CLI flags still override the profile per render.
Resolution order: `--profile` → `$IMPRINT_CONFIG` → `IMPRINT_PROFILE` →
`~/.config/imprint/config.yaml` → `./config.yaml`.

## Metadata: front matter or flags

Per-document metadata lives in **front matter** at the very top of the `.md`.
The preferred form is an HTML comment (invisible in every Markdown viewer);
a `--- … ---` YAML fence also works.

```markdown
<!--
title: "Q2 Architecture Review"
subtitle: "Managed-Kafka Rollout"
description: "How the platform ingests, validates, and routes events."
author: "Jane Doe"
footer_text: "Jane Doe"
category: "Engineering"
date: "June 2026"
recipient: "Acme Corp"
logo: "logo.png"
logo_height: 52
cover: true
confidential: false
-->
# Q2 Architecture Review
```

Every value resolves by precedence: **CLI flag > front matter > config > default**.
The first group below is **document metadata** (front matter / flags only); the
rest are **house-style settings** that default from config but can be overridden
per document.

| Key / flag | Default | Meaning |
|-------------|---------|------------------------------------------------|
| `title` / `--title` | first `# H1` | Document title (the H1 is stripped from the body unless `--keep-h1`) |
| `subtitle` / `--subtitle` | — | Shown under the title on the cover / masthead |
| `description` / `--desc` | — | One-line summary on the cover / masthead |
| `author` / `--author` | — | "Prepared by" on the cover; also the PDF author |
| `footer_text` / `--footer-text` | falls back to `author` | Free text, bottom-left of every page |
| `recipient` / `--recipient` | — | "Prepared for" on the cover |
| `date` / `--date` | — | Free-form date string (e.g. `June 2026`) |
| `category` / `--category` | — | Cover eyebrow + PDF keyword |
| `logo` / `--logo` / `--no-logo` | — (config) | Logo on the cover and running header. A config path resolves relative to the config file, a front-matter path relative to the `.md`; `logo: none` or `--no-logo` drops it |
| `logo_dark_bg` / `--logo-dark-bg` | — (config) | Logo for a dark background, used only on the **gradient** cover (the dark `logo` would vanish on the wash) |
| `logo_height` / `--logo-height` | `40` (config) | Cover logo height in pt (the running-header logo is always 2× the title text) |
| `accent` / `--accent` | `#2563EB` (config) | Theme color (any hex) |
| `cover` / `--cover` `--no-cover` | `false` (config) | Render the title page |
| `cover_style` / `--cover-style` `--gradient` | `light` (config) | Cover look: `light` or `gradient` (an accent wash). Only sets the look — pair it with `cover: true` / `--cover` |
| `confidential` / `--confidential` | `false` (config) | Adds a "Confidential" marker |
| `toc` / `--toc` `--no-toc` | `false` (config) | Add a table of contents (with page numbers) after the cover / masthead |
| `numbered` / `--numbered` `--no-numbered` | `false` (config) | Number the headings (`1`, `1.1`, …). Render-only — your heading text is untouched |
| `lang` / `--lang` | `en` (config) | Body language (BCP 47, e.g. `en-GB`, `de`) for hyphenation and justification |
| `code_font_size` / `--code-font-size` | `9.2` (config) | Block-code font size in pt |
| `template` / `--template` | bundled `default.typ` | Path to a custom Typst template. A config path resolves relative to the config file, a front-matter path relative to the `.md` |

### Custom templates and extra fields

The bundled `default.typ` covers most documents, but you can point imprint at your
own Typst template — per document (`template:` / `--template`) or as a house-style
default in a config or profile. A config-level `template:` resolves next to the
config file (like `logo:`), so a profile can ship its own layout beside its assets:

```yaml
# ~/.config/imprint/profiles/acme.yaml
accent:   "#B91C1C"
logo:     "acme.svg"
template: "acme.typ"     # resolved next to this profile
```

A custom template receives **every key in the table above** as a variable, plus a
**passthrough**: any extra scalar key you set in front matter or config — one the
engine doesn't recognize — is forwarded to the template as a variable of the same
name. So a new field needs no change to imprint itself — just author the template
and set the field:

```markdown
<!--
title: "Master Services Agreement"
template: "contract.typ"
version: "2.1"          # not a built-in key — passed straight to the template
effective_date: "2026-07-01"
-->
```

In the template, read them like any pandoc variable: `$version$`, `$effective_date$`.
Keys must be identifier-like (letters, digits, underscore); `body`, `toc`, and `meta`
are reserved for pandoc.

## Authoring conventions

The source `.md` stays pure Markdown — imprint never mutates it. A few native
constructs are restyled:

- **Callouts.** Any block quote becomes a tinted note box. Lead with a bold
  `**Label.**` to get a colored label.
- **Page breaks.** `<!-- pagebreak -->` on its own line forces a new page.
- **Diagram captions.** A `%% caption: …` line inside a ` ```mermaid ` block
  becomes the figure caption (and is stripped before rendering).
- **Table widths.** Every table spans the full page width; the *ratio* of dashes
  in the separator row sets how that width splits between columns.

## How it works

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the pipeline, the Typst
back-end, and the design tokens. Design rationale lives in
[`docs/decisions/`](docs/decisions/).

## License

MIT for the code. Bundled fonts (Source Sans 3, IBM Plex Sans, JetBrains Mono) are
under the SIL Open Font License — see [`assets/fonts/`](assets/fonts/).
