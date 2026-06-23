// imprint pandoc->Typst template — graphite + blue, config-driven.
// Identity (accent, fonts, logo, author/footer text) is injected from config.yaml
// / front matter / CLI via pandoc -V variables; nothing brand-specific is hardcoded.
// The body rendering preamble below is required by pandoc's Typst writer.

// ---------------- theme tokens ----------------
// Accent: a single configurable color (default a technical blue). Light/dark shades are
// derived from it, so changing `accent` in config re-tints the whole document.
#let accent      = rgb("$if(accent)$$accent$$else$#2563EB$endif$")
#let accent-dark = accent.darken(22%)
#let accent-soft = accent.lighten(90%)   // callout / table-head tint
#let accent-bright = accent.lighten(28%) // lifted accent for highlights on the dark gradient cover
#let heading-ink = rgb("#111827")  // graphite-900 — table-head text, light-cover title
#let ink         = rgb("#1F2937")  // graphite-800 — body text
#let muted       = rgb("#6B7280")  // labels, captions, footer
#let faint       = rgb("#9CA3AF")  // tertiary chrome
#let hairline    = rgb("#E5E7EB")  // rules, borders
#let rule-faint  = rgb("#F3F4F6")  // inline code chip fill
#let surface     = rgb("#F9FAFB")  // code blocks, table head base
// Fonts: families resolved from config; bundled TTFs embedded via --font-path.
// Single bundled family each — rendering runs with --ignore-system-fonts, so a
// system fallback could never be reached anyway (and would only warn).
#let body-font = "$if(font_body)$$font_body$$else$Source Sans 3$endif$"
#let head-font = "$if(font_head)$$font_head$$else$Source Sans 3$endif$"
#let mono-font = "$if(font_mono)$$font_mono$$else$JetBrains Mono$endif$"
#let logo-path = $if(logo)$"$logo$"$else$none$endif$
// A light logo for the dark gradient cover (logo_dark_bg / --logo-dark-bg). The dark
// `logo` would vanish on the wash, so the gradient cover uses this when set and
// otherwise shows no cover logo. Body-page headers always use the normal `logo`.
#let logo-dark-bg-path = $if(logo_dark_bg)$"$logo_dark_bg$"$else$none$endif$
// Running header/footer text size. The header logo derives from this — it is set
// to twice the title text so the logo and title read as a balanced pair on one line.
#let head-size = 8.5pt
// Cover logo height in pt (tunable via logo_height / --logo-height); default 40pt.
// The running-header logo is NOT set here — it is always 2x head-size.
#let logo-height = ($if(logo_height)$$logo_height$$else$40$endif$) * 1pt
// Cover style: "light" (default, a calm pale cover) or "gradient" (an accent wash).
#let cover-style = "$if(cover_style)$$cover_style$$else$light$endif$"
// Body text language (BCP 47, e.g. "en", "en-GB", "de") — drives hyphenation and
// justification. Default English. Pure typesetting, no change to the source text.
// Typst wants the language code and region split apart, so a "lang-REGION" tag is
// parsed into a 2-3 letter code plus an optional uppercase region.
#let lang-tag = "$if(lang)$$lang$$else$en$endif$"
#let lang-parts = lang-tag.split("-")
#let doc-lang = lang-parts.at(0)
#let doc-region = if lang-parts.len() > 1 { upper(lang-parts.at(1)) } else { none }
// Block code size: an absolute pt when `code_font_size` is set, else 0.92em — the
// same size as before, so unset output is unchanged. Inline code keeps 0.92em.
#let code-block-size = $if(code_font_size)$($code_font_size$ * 1pt)$else$0.92em$endif$
// Opt-in heading numbering (numbered: true), a reversible render-time toggle — the
// numbers live only in the layout, never in the source text. The first H1 becomes
// the (stripped) title, so body sections start at H2; trimming leading zero
// counters makes the shallowest body heading the top number (H2 -> "1", an H3
// under it -> "1.1"). With --keep-h1 the H1 is non-zero and nothing is trimmed.
#let heading-numbering = (..n) => {
  let nums = n.pos()
  while nums.len() > 1 and nums.first() == 0 { nums = nums.slice(1) }
  numbering("1.1.1.1.1.1", ..nums)
}
// Gradient cover (opt-in): a 45° diagonal wash echoing proof — a dark, neutral
// slate anchor at the top-left flowing through a deep accent to the accent itself
// at the bottom-right, with two soft accent glows over it. The slate anchor is a
// fixed neutral (it keeps the cover dark so the lifted-accent highlights read
// against it); the accent drives the rest, so the wash still re-tints with the
// theme.
#let cover-slate = rgb("#0F172A")   // slate-900 — the dark gradient anchor (proof's cover-top)
// Mid stop, derived dark. proof pins a deep teal (#115E59) at 60%; a generic
// accent.darken(38%) lands on the same lightness, so the upper-middle of the wash
// stays dark and the slate anchor reads — instead of lifting straight into a flat
// bright accent. Tuned against proof's LattIQ-green cover; re-tints with any accent.
#let cover-grad = gradient.linear(angle: 45deg,
  (cover-slate, 0%), (accent.darken(38%), 60%), (accent, 100%))
// Two soft radial glows over the wash: a brighter halo top-right (behind the logo)
// and a subtler, deeper one bottom-left — echoing proof's two-tone emeralds
// (#34D399 / #10B981), but derived from accent so the cover still re-tints.
#let cover-glow-tr = accent.lighten(34%)
#let cover-glow-bl = accent.lighten(18%)
#let cover-glows = {
  place(top + left, rect(width: 100%, height: 100%, fill: gradient.radial(
    (cover-glow-tr.transparentize(66%), 0%), (cover-glow-tr.transparentize(100%), 70%),
    (cover-glow-tr.transparentize(100%), 100%), center: (85%, 18%), radius: 75%)))
  place(top + left, rect(width: 100%, height: 100%, fill: gradient.radial(
    (cover-glow-bl.transparentize(80%), 0%), (cover-glow-bl.transparentize(100%), 70%),
    (cover-glow-bl.transparentize(100%), 100%), center: (12%, 82%), radius: 75%)))
}

// Sleek section divider for `---`: a short, centred accent rule with round caps.
#let horizontalrule = align(center, block(above: 1.6em, below: 1.6em,
  line(length: 9%, stroke: (paint: accent, thickness: 1.4pt, cap: "round"))))

// pandoc compatibility: older pandoc Typst writers emit `#blockquote[...]` for
// block quotes, while newer ones emit `#quote(block: true)[...]`. Alias the former
// to a real quote element so the callout `show` rule styles both — this keeps
// imprint working on stock distro pandoc (e.g. Ubuntu 24.04's 3.1.3), not only the
// latest release.
#let blockquote(body) = quote(block: true, body)

#show terms.item: it => block(breakable: false)[
  #text(weight: "bold")[#it.term]
  #block(inset: (left: 1.5em, top: -0.4em))[#it.description]
]

#set table(inset: 6pt, stroke: none)
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: image): set figure.caption(position: bottom)

$if(highlighting-definitions)$
$highlighting-definitions$
$endif$
#set smartquote(enabled: false)

#let conf(
  title: none, subtitle: none, description: none,
  authors: (), date: none, recipient: none, confidential: false,
  category: none, cover: false, toc: false, numbered: false, footer-text: none,
  doc,
) = {
  // PDF metadata (viewer tab / Get Info). Author is set only from an explicit
  // author (footer text is free-form, not necessarily a person, so it is not
  // used here); keywords carry the category when present.
  let meta-author = authors
  let meta-keywords = if category != none { (category,) } else { () }
  set document(title: title, author: meta-author, keywords: meta-keywords)
  set page("a4", margin: (x: 2.2cm, top: 2.5cm, bottom: 2.0cm))
  set text(font: body-font, size: 10pt, fill: ink, lang: doc-lang, region: doc-region)
  set par(justify: true, leading: 0.65em, spacing: 1.0em)
  set list(spacing: 0.8em)
  set enum(spacing: 0.8em)

  // Headings: accent sans, matching proof (proof colors every heading in its
  // brand; imprint uses the configurable accent). H1 is the largest with extra
  // air above and below; deeper levels step down in size. Plain — no rules.
  show heading: set text(fill: accent, font: head-font, weight: 700)
  show heading: set block(above: 1.4em, below: 0.95em, sticky: true)
  show heading.where(level: 2): set text(size: 13.5pt)
  show heading.where(level: 3): set text(size: 11.5pt)
  show heading.where(level: 4): set text(size: 10.5pt)
  show heading.where(level: 5): set text(size: 10pt)
  show heading.where(level: 6): set text(size: 9.5pt)
  show heading.where(level: 1): set block(above: 1.9em, below: 1.15em)
  show heading.where(level: 1): set text(size: 17pt)
  // Opt-in section numbering (off by default, so output stays 1:1 with the source).
  set heading(numbering: if numbered { heading-numbering } else { none })

  // Task-list checkboxes (the sans lacks the ballot glyphs, so draw them).
  show "☐": box(width: 0.8em, height: 0.8em, stroke: 0.7pt + muted, radius: 2pt, baseline: 0.12em)
  show "☒": box(width: 0.8em, height: 0.8em, fill: accent, radius: 2pt, baseline: 0.12em)
  show link: set text(fill: accent-dark)
  // Code: inline chips (faint fill) and blocks (soft surface, hairline frame).
  show raw: set text(font: mono-font, size: 0.92em)
  show raw.where(block: false): box.with(
    fill: rule-faint, inset: (x: 4pt, y: 0pt), outset: (y: 3pt), radius: 2pt,
  )
  show raw.where(block: true): block.with(
    fill: surface, inset: 9pt, radius: 4pt, width: 100%,
    stroke: 0.5pt + hairline,
  )
  // Block code size (code_font_size); default 0.92em keeps current output.
  show raw.where(block: true): set text(size: code-block-size)
  // Callouts: a Markdown block quote renders as a tinted note box with an accent
  // left bar and a bold colored lead-in label.
  show quote.where(block: true): it => block(
    width: 100%, fill: accent-soft, inset: (left: 14pt, rest: 11pt),
    above: 0.9em, below: 0.9em,
    radius: (right: 3pt), stroke: (left: 3pt + accent),
    {
      set par(justify: false, leading: 0.6em)
      set text(fill: ink)
      show strong: set text(fill: accent-dark, weight: 700)
      it.body
    },
  )

  // Diagrams / images: a centered figure inside a rounded hairline frame,
  // caption in muted italic below.
  show figure.where(kind: image): set figure(supplement: none, numbering: none)
  show figure.caption: set text(size: 9pt, fill: muted, style: "italic")
  show figure.where(kind: image): it => block(
    width: 100%, inset: 14pt, radius: 6pt, stroke: 0.5pt + hairline,
    above: 1.8em, below: 1.8em,
    align(center, it),
  )

  // Tables: rounded hairline frame, tinted header row, hairline row dividers.
  show table.cell: set par(justify: false)
  show table.cell: set text(size: 9.5pt)
  set table.cell(align: left + top)
  show table.cell.where(y: 0): set text(weight: 700, fill: heading-ink, hyphenate: true)
  set table(
    inset: (x: 9pt, y: 7pt),
    stroke: (_, y) => (bottom: 0.5pt + hairline),
    fill: (_, y) => if y == 0 { accent-soft },
  )
  show table: it => block(
    radius: 6pt, stroke: 0.5pt + hairline, inset: 0pt,
    above: 1.8em, below: 1.8em, it,
  )
  show figure.where(kind: table): set block(breakable: true)

  // Footer (body pages): footer text, then category, then a Confidential marker —
  // each appended only when set, joined by an em dash (mirrors proof's footer
  // line "LattIQ × Acme — Engineering — Confidential"). Page number sits right.
  let footLeft = {
    let parts = ()
    if footer-text != none { parts.push(text(fill: ink, weight: 600)[#footer-text]) }
    if category != none { parts.push(text(fill: ink)[#category]) }
    if confidential { parts.push(text(fill: muted)[Confidential]) }
    parts.join(text(fill: muted)[ — ])
  }

  // ===================== OPTIONAL COVER (off by default) =====================
  // A title page: category eyebrow + optional CONFIDENTIAL marker top-right, an
  // optional logo top-left, the title block, then a "Prepared for / Prepared by"
  // band. Shown only when `cover: true`, in one of two styles (`cover_style`):
  // the default calm "light" cover, or a "gradient" accent wash. The layout is
  // shared; the two styles differ only in their fills and logo.
  let coverBody(titleFill, subFill, descFill, eyebrowFill, confFill, labelFill, valueFill, logoBlock) = {
    set par(justify: false, leading: 0.5em)
    let eyebrow(fill, body) = text(size: 8pt, font: head-font, tracking: 0.16em, weight: 700, fill: fill)[#body]
    let topTags = ()
    if category != none { topTags.push(eyebrow(eyebrowFill, upper(category))) }
    if confidential { topTags.push(eyebrow(confFill, [CONFIDENTIAL])) }
    grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
      logoBlock,
      if topTags.len() > 0 { align(right, par(leading: 0.7em, topTags.join(linebreak()))) } else [],
    )
    v(1fr)
    if title != none { text(font: head-font, size: 32pt, fill: titleFill, weight: 600)[#title] }
    if subtitle != none { v(0.5em); text(size: 15pt, fill: subFill, weight: 600)[#subtitle] }
    if description != none { v(0.9em); block(width: 82%, text(size: 11pt, fill: descFill)[#description]) }
    let metaCol(label, value) = stack(spacing: 0.55em,
      text(size: 8pt, font: head-font, tracking: 0.18em, weight: 700, fill: labelFill)[#label],
      text(size: 12pt, weight: 500, fill: valueFill)[#value],
    )
    let cells = ()
    if recipient != none { cells.push(metaCol("PREPARED FOR", recipient)) }
    if authors.len() > 0 { cells.push(metaCol("PREPARED BY", authors.join(", "))) }
    if cells.len() > 0 {
      v(1.7em)
      grid(columns: cells.map(_ => auto), column-gutter: 3.5em, ..cells)
    }
    v(2.2fr)
  }
  if cover and cover-style == "gradient" {
    page(fill: cover-grad, background: cover-glows, numbering: none, header: none,
      margin: (x: 2.2cm, top: 2.5cm, bottom: 2.0cm),
      footer: {
        set text(size: 8.5pt, fill: white.transparentize(25%))
        grid(columns: (1fr, auto),
          if confidential [Proprietary — Do not distribute] else [],
          align(right)[#if date != none { date }])
      },
      coverBody(white, accent-bright, white.transparentize(20%), accent-bright,
        white.transparentize(28%), accent-bright, white,
        if logo-dark-bg-path != none { image(logo-dark-bg-path, height: logo-height, alt: "logo") } else []),
    )
  } else if cover {
    page(numbering: none, header: none,
      footer: {
        set text(size: 8.5pt, fill: muted)
        grid(columns: (1fr, auto),
          if confidential [Proprietary — Do not distribute] else [],
          align(right)[#if date != none { date }])
      },
      coverBody(heading-ink, accent-dark, muted, accent-dark, muted, accent-dark, ink,
        if logo-path != none { image(logo-path, height: logo-height, alt: "logo") } else []),
    )
  }

  // ===================== BODY PAGES =====================
  // Titled running header: optional logo (left) and the document title (right),
  // sharing a common baseline, over a thin rule. The logo is sized to twice the
  // title text (it rises above the shared baseline). Bottom-aligning keeps the
  // title-to-rule gap equal to the footer's rule-to-text gap. Footer: the optional
  // footer text (left) and the page number (right).
  set page(
    numbering: "1",
    header: context {
      // With a masthead (no cover), the first body page carries the title block,
      // so the running header only begins on the second page. With a cover, every
      // body page gets the header.
      if cover or counter(page).get().first() > 1 {
        set text(size: head-size, fill: muted)
        grid(columns: (1fr, auto), align: bottom,
          align(left + bottom)[#if logo-path != none { image(logo-path, height: head-size * 2, alt: "logo") }],
          align(right + bottom)[#if title != none { title }],
        )
        v(2pt)
        line(length: 100%, stroke: 0.5pt + hairline)
      }
    },
    footer: {
      set text(size: 8.5pt, fill: muted)
      line(length: 100%, stroke: 0.5pt + hairline)
      v(2pt)
      grid(columns: (1fr, auto),
        align(left)[#footLeft],
        align(right)[#context counter(page).display()],
      )
    },
  )
  counter(page).update(1)
  // Masthead: with no cover page, open the first body page with a title block —
  // title, subtitle, description — so the document still has a proper title
  // treatment (not just the small running header). Mirrors the light cover's
  // hierarchy: dark title, accent subtitle, muted description, over a thin rule.
  if not cover and title != none {
    block(below: 1.7em, {
      set par(justify: false, leading: 0.5em)
      text(font: head-font, size: 24pt, fill: heading-ink, weight: 700)[#title]
      if subtitle != none { v(0.45em); text(size: 14pt, fill: accent-dark, weight: 600)[#subtitle] }
      if description != none { v(0.6em); block(width: 88%, text(size: 10.5pt, fill: muted)[#description]) }
      v(0.85em)
      line(length: 100%, stroke: 0.5pt + hairline)
    })
  }
  // Optional table of contents (toc: true) — navigation furniture derived purely
  // from the headings already in the document; off by default. Page numbers are
  // something the Markdown source cannot carry, so this adds, never mutates. The
  // TOC follows the cover/masthead and ends with a page break so the body starts
  // clean. Depth 3 lists the top two body levels (H2 sections, H3 subsections).
  if toc {
    block(below: 1.6em, {
      text(font: head-font, size: 15pt, fill: accent, weight: 700)[Contents]
      v(0.7em)
      set text(fill: ink)
      show outline.entry.where(level: 1): set block(above: 0.9em)
      outline(title: none, depth: 3, indent: 1.2em)
    })
    pagebreak(weak: true)
  }
  doc
}

#show: doc => conf(
$if(title)$  title: [$title$],$endif$
$if(subtitle)$  subtitle: [$subtitle$],$endif$
$if(description)$  description: [$description$],$endif$
$if(date)$  date: [$date$],$endif$
$if(recipient)$  recipient: [$recipient$],$endif$
$if(category)$  category: "$category$",$endif$
$if(confidential)$  confidential: true,$endif$
$if(cover)$  cover: true,$endif$
$if(toc)$  toc: true,$endif$
$if(numbered)$  numbered: true,$endif$
$if(footer_text)$  footer-text: [$footer_text$],$endif$
  authors: ($for(author)$"$author$", $endfor$),
  doc,
)

$body$
