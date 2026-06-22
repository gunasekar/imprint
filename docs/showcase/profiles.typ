// Showcase strip: one document, three org profiles (accent + logo). Composed by
// `make showcase` from the per-org gradient covers rendered into .tmp/showcase/.
// Paths are root-relative (compiled with --root at the repo root).
#set page(width: 760pt, height: 452pt, margin: (x: 22pt, top: 20pt, bottom: 16pt), fill: rgb("#FFFFFF"))
#set text(font: "Source Sans 3", fill: rgb("#1F2937"))
#align(center)[
  #text(size: 15pt, weight: 700)[Set your brand once. A profile per org.]
  #v(2pt)
  #text(size: 10pt, fill: rgb("#6B7280"))[The same `examples/sample.md` under three profiles — each profile is just an accent color and a logo.]
]
#v(11pt)
#grid(columns: (1fr, 1fr, 1fr), gutter: 16pt,
  ..(("/.tmp/showcase/acme.png", "acme"),
     ("/.tmp/showcase/contoso.png", "contoso"),
     ("/.tmp/showcase/fabrikam.png", "fabrikam")).map(it => {
    block(radius: 6pt, clip: true, stroke: 0.5pt + rgb("#E5E7EB"), image(it.at(0), width: 100%))
    v(5pt)
    align(center, text(font: "JetBrains Mono", size: 9pt, fill: rgb("#6B7280"))[imprint report.md --profile #it.at(1)])
  })
)
