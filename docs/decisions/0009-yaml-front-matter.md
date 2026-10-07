# 0009 — Standard YAML front matter, parsed by pandoc

- Status: Accepted
- Date: 2026-07-13

## Context

imprint had two metadata conventions of its own making, and both were liabilities.

**A private delimiter.** Front matter was preferably written inside an HTML comment
(`<!-- title: … -->`) rather than a `---` fence. The motivation was cosmetic and real:
GitHub renders a YAML fence as a metadata table above the document, and a comment is
invisible everywhere.

But an HTML comment is, by definition, *not data*. Every conforming Markdown tool is
supposed to discard it, and they do. That is not a theoretical cost — it is exactly why
rendering `examples/sample.md` through the new Quarto format produced a document with
**no metadata at all**: no cover, no title, no accent. Quarto behaved correctly;
imprint was the one reading data out of a comment.

**A private parser.** Both the front matter and `config.yaml` were read by a ~20-line
flat `key: value` regex. It had no notion of types, lists, nesting, multi-line scalars,
or YAML quoting rules — so a file named `.yaml` was not, in fact, YAML. Every user who
knew YAML had to learn where imprint's dialect stopped.

Together these blocked the thing that makes the Quarto extension worth having: one
source file that both tools can read.

## Decision

**Front matter is a standard `---` YAML fence.** The same block pandoc, Quarto, Jekyll,
and Hugo read. The HTML-comment form is not accepted — it was a private convention no
other tool could read, and keeping it would block the Quarto goal of one portable
source file.

**YAML is parsed by pandoc, not by imprint.** pandoc is already a hard dependency and
ships a real YAML parser, so imprint shells out to it:

```
pandoc <fence> -f markdown-smart -t plain --template='$meta-json$'   ->  JSON
                                                                          |
                                                        stdlib json.loads |
```

`$meta-json$` is pandoc's built-in "metadata as JSON" template variable. This applies to
`config.yaml` too — one parser for both, and `parse_flat()` is deleted.

The payoff is not just correctness, it is *the absence of a dialect*: imprint's YAML
semantics are pandoc's semantics, which are Quarto's semantics. There is nothing
imprint-specific left to document, and nothing that can drift.

`-smart` is disabled deliberately: metadata reaches the Typst template as a raw string,
so quotes and dashes must arrive verbatim rather than typographically prettified.

### Why not PyYAML

It is the obvious library, and it would cost the README's "stdlib only, no pip packages"
promise plus an install step for every user — to buy a parser imprint already has on
the machine. The footprint stays exactly as it was: pandoc, typst, python3, bash.

### The one migration hazard, guarded

Under the old flat parser `accent: #2563EB` worked. In real YAML an unquoted `#` opens a
comment, so that line parses to an *empty* value and the document would quietly render
in the default blue. imprint detects that shape in both config and front matter and
**stops with an error** naming the fix (`accent: "#2563EB"`). A silently wrong brand
color is worse than a stopped build.

## Consequences

- Documents that still use `<!-- … -->` front matter lose their metadata until
  converted to a `---` fence — a deliberate break; the comment form was never
  portable.
- One source file can now feed both imprint and Quarto. Verified: the same `.md`
  rendered through both produced pixel-identical covers.
- YAML behaves as users expect: booleans, numbers, comments, quoting, multi-line
  scalars, and lists. A list-valued `author:` joins the way the template's
  `authors.join(", ")` renders it anyway, so output is unchanged.
- Two extra pandoc invocations per render (config + front matter). pandoc is fast and
  already in the pipeline.
- Front matter is now **visible** on GitHub as a metadata table. That is the price of
  the standard, and it is a cosmetic cost on a page nobody reads for the metadata. It
  shrinks if house-style keys live in `config.yaml` where they belong — see
  [ADR 0002](0002-render-config-vs-document-metadata.md).
- `README.md` carries **no** front matter at all: it is a landing page first, so its
  metadata moved to flags in `make readme` rather than put a table above the title.
