# imprint

Turn Markdown into branded, typeset PDFs — the specs, design docs, and reports
that need to look official. One command gives you a title page, a running
header/footer, and a consistent house style, with your content flowed straight
through. Determinism is built in: a fixed pandoc → Typst pipeline means the same
input always produces the same output. Rendering settings (theme accent, fonts,
default toggles) come from a config file; document metadata (title, author,
footer text, logo) comes from each document's front matter — so the repo stays
brand-free and public-safe.

## Working in this repo

```bash
make install   # symlink ./imprint onto PATH, then report prerequisite status
make config    # scaffold ~/.config/imprint/config.yaml from the example
make check     # verify prereqs: pandoc, python3, typst (+ mmdc for Mermaid)
make lint-md   # lint the Markdown docs (CI runs this too; needs node/npx)
make example   # render examples/sample.md -> examples/sample.pdf
```

Run it directly:

```bash
./imprint INPUT.md [-o OUT.pdf]   # output defaults to INPUT.pdf
```

Prerequisites (macOS): `brew install pandoc typst` and, only for docs with
Mermaid, `brew install mermaid-cli`. On Linux: install pandoc ≥ 3 from its
[GitHub releases](https://github.com/jgm/pandoc/releases), `cargo install
--locked typst-cli`, and `npm install -g @mermaid-js/mermaid-cli` for Mermaid.
`python3`/`bash` are stdlib only.

## How it fits together

`imprint` is a single bash wrapper. It reads a config file (rendering settings:
theme + default toggles) and the source `.md`'s front matter — an `<!-- … -->`
comment block (preferred) or a `--- … ---` fence. Config contributes only the
render keys; the front matter supplies document metadata and may override the
render defaults; CLI flags override everything. An inline python3 preprocessor
copies local images into a build dir, pre-renders Mermaid blocks to SVG, and
rewrites native constructs (page breaks); the wrapper resolves and copies any
document logo. Then pandoc → Typst typesets the PDF against one template,
`templates/default.typ`. Fonts are vendored in `assets/fonts/` and embedded by
Typst, so output is self-contained and reproducible.

The source `.md` stays pure Markdown — imprint never mutates it; all rewrites
happen on a build copy.

## Guardrails

- **Nothing personal in the repo.** Config holds only rendering settings (theme
  accent, fonts, default toggles) — a reusable house style, no document content.
  Document identity (title, author, footer text, logo) comes from each document's
  front matter or a CLI flag, never config. `config.yaml` is gitignored; the
  committed `config.example.yaml` holds rendering defaults only. Keep it that
  way — the repo is meant to be public.
- **Deterministic render path** — no network calls, no time-dependent defaults.
  Optional values are omitted when unset, never filled.
- **One template.** Theme changes go in `templates/default.typ`; the accent is a
  single token derived into light/dark shades, so most re-theming is one value.
- Record non-trivial design changes as an ADR in `docs/decisions/`, and mark the
  superseded one's Status rather than rewriting it.

## Pointers

- **Usage** (flags, front matter, config, authoring conventions) → `README.md`
- **Internals** (pipeline, the Typst back-end, repo layout, design tokens) →
  `docs/ARCHITECTURE.md`
- **Design rationale** → `docs/decisions/`
