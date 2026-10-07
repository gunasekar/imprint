# 0008 — Ship the template as a Quarto format extension

- Status: Accepted
- Date: 2026-07-12

## Context

imprint's asset is its Typst template, not its Bash CLI. Quarto already reaches the
docs and scientific-writing audience, renders Typst, and can load a custom Typst
template through a *format extension*. The common objection to imprint — "Quarto
already does this" — is best answered not by arguing, but by shipping the look **as a
Quarto format**, so imprint becomes *how you get this look in Quarto*.

That gives two products over one template: the CLI for people who do not use Quarto,
and `imprint-typst` for people who do. The whole point collapses if the two drift, so
the real design question is not "should we ship it" but "how do the two stay the same
document".

## Decision

Ship the extension from **this repo**, under `quarto/_extensions/imprint/`. Quarto
supports `quarto add owner/repo/subdir@tag`, so a subdirectory needs no second repo,
no second release, and no cross-repo template sync.

Split the template at the boundary Quarto already uses, and let both consumers read
the same files:

```
templates/typst-template.typ   theme tokens + conf()          ─┐  byte-identical
templates/typst-show.typ       metadata -> conf(...)          ─┤  copies, enforced
templates/default.typ          CLI main template: the two      │  by `make quarto-check`
                               partials + $body$               │
quarto/_extensions/imprint/                                    │
    typst-template.typ  ◄──────────────────────────────────────┘
    typst-show.typ      ◄──────────────────────────────────────┘
```

Quarto's own Typst template is assembled from pandoc partials named exactly
`typst-template.typ` and `typst-show.typ`, so the CLI's `default.typ` can include the
same two partials and add `$body$`. One look, two entry points.

Three metadata keys had to be reconciled so that one file serves both callers. Each is
a Quarto constraint, not a preference. imprint adopts the Quarto-safe name as its own
canonical key (see [ADR 0010](0010-canonical-metadata-keys.md)) so the two tools share
one spelling:

| Key | Why |
|---|---|
| `accent` | pandoc escapes a literal `#` to `\#`, which Typst rejects inside `rgb()`. The template writes the `#` itself and both callers pass a bare hex. |
| `headerlogo` | Quarto reserves `logo` and coerces it to a boolean, so `headerlogo` is the shared key (the CLI keeps `logo` as an alias). |
| `docdate` | Quarto parses `date` into a real date and reformats free text, so `docdate` is the shared key (the CLI keeps `date` as an alias). |

### The copies are copies, not symlinks

`quarto add` installs `_extensions/imprint/` and **nothing outside it**, so the shared
files must physically live inside the extension. A symlink up into `templates/` was
tried and rejected: Quarto copies a symlink *as a symlink*, so the installed extension
ends up with a dangling link into a `templates/` directory that does not exist on the
user's machine.

So the extension holds real copies, refreshed by `make quarto-sync` and policed by
`make quarto-check` in CI. Because the three keys above are reconciled *in the shared
files*, the copy is a plain `cp` and the drift check is a plain `cmp` — there is no
transform to get wrong, and one place to edit.

### Fonts are bundled, at a project-root-relative path

The CLI renders hermetically from `assets/fonts`. The extension bundles the same fonts
and points at them with `font-paths: [/_extensions/imprint/fonts]`.

The leading `/` means *project-root-relative*. Without it the path resolves against the
document's directory, so a document in a subfolder silently misses the fonts and Typst
falls back to a system face — a wrong-looking PDF that still renders, with only a
warning. Declaring the fonts via `brand:` inside `_extension.yml` was tried first and
does not work: Quarto ignores it and fetches nothing.

## Consequences

- One template, two products. A look change is made once, in `templates/`.
- CI fails if the extension drifts, so the copies cannot silently rot.
- The extension is self-contained: no system font install, no network fetch.
- `assets/fonts` is duplicated (~2.5 MB) inside the extension. That is the price of
  `quarto add` only installing the extension directory, and it is paid in bytes rather
  than in a broken render on someone else's machine.
- Quarto-specific fixes that the shared template must not know about live in
  `imprint-quarto.typ` (injected via `include-in-header`) and `imprint.lua`.

## Publishing

Users install with:

```sh
quarto add gunasekar/imprint/quarto
```

To list it in the [Quarto extensions registry](https://github.com/mcanouil/quarto-extensions),
whose entry format is `<owner>/<repository>/<optional-path>`:

- [x] Extension lives under `_extensions/` within the submitted path (`quarto/`)
- [x] The path contains an `example.qmd` — `quarto/example.qmd`, which renders in
      place against `quarto/_extensions/`
- [x] `_extension.yml` carries `title`, `author`, `version`, `quarto-required`
- [ ] GitHub repo **Description** populated (no backticks)
- [ ] GitHub repo **Topics** added (include `quarto-extension`; optionally a status
      topic such as `experimental` or `stable`)
- [ ] At least one **Release** with a tag (e.g. `v0.1.0`) — the extension is
      versioned independently of the CLI via `_extension.yml`'s `version`
- [ ] PR adding `gunasekar/imprint/quarto` to `extensions/quarto-extensions.csv`

## Alternatives considered

- **A separate `imprint-quarto` repo.** The conventional layout, and it gives a tidier
  install string. Rejected: it splits one template across two repos and two release
  cycles, which is exactly the drift this decision exists to prevent.
- **Symlinking the shared files into the extension.** True zero-copy single source.
  Rejected on evidence — see above.
- **Generating the extension's `.typ` files by transforming the CLI's.** Once the three
  keys are reconciled, there is nothing left to transform, so the transform would be
  pure ceremony.
