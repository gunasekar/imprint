// imprint pandoc->Typst template — graphite + teal, config-driven.
// Identity (accent, fonts, logo, author/footer text) is injected from config.yaml
// / front matter / CLI via pandoc -V variables; nothing brand-specific is hardcoded.
// The body rendering preamble below is required by pandoc's Typst writer.

// ---------------- theme tokens ----------------
// Accent: a single configurable color (default a technical blue). Light/dark shades are
// derived from it, so changing `accent` in config re-tints the whole document.
#let accent      = rgb("$if(accent)$$accent$$else$#2563EB$endif$")
#let accent-dark = accent.darken(22%)
#let accent-soft = accent.lighten(90%)   // callout / table-head tint
#let heading-ink = rgb("#111827")  // graphite-900 — headings
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
// Running header/footer text size. The header logo derives from this — it is set
// to twice the title text so the logo and title read as a balanced pair on one line.
#let head-size = 8.5pt
// Cover logo height in pt (tunable via logo_height / --logo-height); default 40pt.
// The running-header logo is NOT set here — it is always 2x head-size.
#let logo-height = ($if(logo_height)$$logo_height$$else$40$endif$) * 1pt

// Sleek section divider for `---`: a short, centred accent rule with round caps.
#let horizontalrule = align(center, block(above: 1.6em, below: 1.6em,
  line(length: 9%, stroke: (paint: accent, thickness: 1.4pt, cap: "round"))))

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
  category: none, cover: false, footer-text: none,
  doc,
) = {
  // PDF metadata (viewer tab / Get Info). Author is set only from an explicit
  // author (footer text is free-form, not necessarily a person, so it is not
  // used here); keywords carry the category when present.
  let meta-author = authors
  let meta-keywords = if category != none { (category,) } else { () }
  set document(title: title, author: meta-author, keywords: meta-keywords)
  set page("a4", margin: (x: 2.2cm, top: 2.5cm, bottom: 2.0cm))
  set text(font: body-font, size: 10pt, fill: ink)
  set par(justify: true, leading: 0.65em, spacing: 1.0em)
  set list(spacing: 0.8em)
  set enum(spacing: 0.8em)

  // Headings: graphite sans. H1 is the largest with extra air above and below;
  // deeper levels step down in size. Plain (no rules), matching proof.
  show heading: set text(fill: heading-ink, font: head-font, weight: 700)
  show heading: set block(above: 1.4em, below: 0.95em, sticky: true)
  show heading.where(level: 2): set text(size: 13.5pt)
  show heading.where(level: 3): set text(size: 11.5pt)
  show heading.where(level: 4): set text(size: 10.5pt)
  show heading.where(level: 5): set text(size: 10pt)
  show heading.where(level: 6): set text(size: 9.5pt)
  show heading.where(level: 1): set block(above: 1.9em, below: 1.15em)
  show heading.where(level: 1): set text(size: 17pt)

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
  // A calm, light title page: category eyebrow + optional CONFIDENTIAL marker
  // top-right, optional logo top-left, the title block, then a "Prepared for /
  // Prepared by" band. Shown only when `cover: true`.
  if cover {
    page(numbering: none, header: none,
      footer: {
        set text(size: 8.5pt, fill: muted)
        grid(columns: (1fr, auto),
          if confidential [Proprietary — Do not distribute] else [],
          align(right)[#if date != none { date }])
      },
      {
        set par(justify: false, leading: 0.5em)
        let eyebrow(fill, body) = text(size: 8pt, font: head-font, tracking: 0.16em, weight: 700, fill: fill)[#body]
        let topTags = ()
        if category != none { topTags.push(eyebrow(accent-dark, upper(category))) }
        if confidential { topTags.push(eyebrow(muted, [CONFIDENTIAL])) }
        grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
          if logo-path != none { image(logo-path, height: logo-height, alt: "logo") } else [],
          if topTags.len() > 0 { align(right, par(leading: 0.7em, topTags.join(linebreak()))) } else [],
        )
        v(1fr)
        if title != none { text(font: head-font, size: 32pt, fill: heading-ink, weight: 600)[#title] }
        if subtitle != none { v(0.5em); text(size: 15pt, fill: accent-dark, weight: 600)[#subtitle] }
        if description != none { v(0.9em); block(width: 82%, text(size: 11pt, fill: muted)[#description]) }
        let metaCol(label, value) = stack(spacing: 0.55em,
          text(size: 8pt, font: head-font, tracking: 0.18em, weight: 700, fill: accent-dark)[#label],
          text(size: 12pt, weight: 500, fill: ink)[#value],
        )
        let cells = ()
        if recipient != none { cells.push(metaCol("PREPARED FOR", recipient)) }
        if authors.len() > 0 { cells.push(metaCol("PREPARED BY", authors.join(", "))) }
        if cells.len() > 0 {
          v(1.7em)
          grid(columns: cells.map(_ => auto), column-gutter: 3.5em, ..cells)
        }
        v(2.2fr)
      },
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
    header: {
      set text(size: head-size, fill: muted)
      grid(columns: (1fr, auto), align: bottom,
        align(left + bottom)[#if logo-path != none { image(logo-path, height: head-size * 2, alt: "logo") }],
        align(right + bottom)[#if title != none { title }],
      )
      v(2pt)
      line(length: 100%, stroke: 0.5pt + hairline)
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
$if(footer_text)$  footer-text: [$footer_text$],$endif$
  authors: ($for(author)$"$author$", $endfor$),
  doc,
)

$body$
