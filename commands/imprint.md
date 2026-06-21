---
description: Prep a Markdown file with imprint front matter + authoring conventions for clean PDF rendering
argument-hint: <path/to/source.md>
---

Prepare the Markdown file at `$ARGUMENTS` for rendering with **imprint** — the
deterministic Markdown → PDF tool, installed as the `imprint` command on your PATH.
imprint reads front matter (an HTML-comment block, or a `---` fence) for cover/
footer metadata and restyles a handful of native Markdown constructs; this
command edits the file in place to add those.

## Step 1: Read imprint's conventions (source of truth)

Locate imprint's repo from the installed binary, then read its `README.md` — don't
hardcode a path or work from memory:

```bash
imprint_dir=$(dirname "$(readlink "$(command -v imprint)")")   # repo root, from the PATH symlink
echo "$imprint_dir/README.md"
```

Read `$imprint_dir/README.md`. Two sections are the spec:

- **"Metadata: front matter or flags"** — the exact front-matter keys imprint
  accepts and their defaults.
- **"Authoring conventions"** — the native-Markdown constructs imprint restyles
  (callouts, mermaid captions, page breaks, table column widths).

(If `command -v imprint` finds nothing, imprint isn't installed — run `make install`
in the imprint repo, then retry.)

## Step 2: Add front matter

Insert the metadata block at the very top of the file as an **HTML comment**
(`<!-- … -->`, on its own lines) — imprint reads it, but every Markdown viewer
hides it, unlike a `---` fence which GitHub and VS Code render. Infer each value
from the document and **state every inferred value**. Keys (omit any that don't
apply — imprint omits unset optionals):

- `title` — the document's first `# H1` (imprint strips it from the body).
- `subtitle` — a short version/scope line if the doc has one.
- `description` — one sentence from the opening/purpose.
- `category` — the document's function area (e.g. `Engineering`, `Documentation`).
  Shown as a cover eyebrow and added to the PDF keywords. Omit if unclear.
- `date` — only if the document states one; otherwise omit.
- `recipient` — who the doc is "Prepared for" (only meaningful with a cover).
- `cover` — `true` only if the user wants a title page; defaults to `false`.
- `cover_style` — `gradient` only if the user wants the bolder accent-wash cover
  (it implies a cover); otherwise omit for the default light cover.
- `confidential` — `true` for sensitive documents; `false` otherwise.

`cover` and `confidential` change the document's framing, so **confirm those two
with the user** before finalizing; infer the rest. Personal identity (author,
footer text, accent) comes from the user's config — do **not** add it to front
matter.

## Step 3: Apply authoring conventions

Add imprint constructs only — **do not rewrite the prose**:

- **Mermaid captions.** Give each ` ```mermaid ` block a `%% caption: …` first
  line describing the diagram (imprint turns it into the figure caption).
- **Page breaks.** Insert `<!-- pagebreak -->` on its own line at natural section
  boundaries — especially before a large diagram or table.
- **Callouts.** Ensure important block quotes lead with a bold `**Label.**` (e.g.
  `> **Note.** …`) so the label is colored.
- **Table widths.** Every table spans the full page width; the *ratio* of dashes
  in the separator row sets how that width is split. Adjust dashes only where the
  default split short-changes a column; leave balanced tables alone.

## Step 4: Report and hand off

Print a short report and the render command:

| Item | Value |
|------|-------|
| File | `$ARGUMENTS` |
| Front matter added | title / subtitle / category / … (list what was set) |
| Mermaid captions | N added |
| Page breaks | N inserted |

Then give the command to render it (imprint is on the PATH, so it runs from anywhere):

```
imprint <path/to/source.md>             # -> <source without .md>.pdf
imprint <path/to/source.md> --cover     # add a light title page
imprint <path/to/source.md> --gradient  # add a gradient (accent-wash) title page
```
