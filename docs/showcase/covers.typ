// Showcase strip: the cover is optional — masthead (default) vs a light cover.
// Composed by `make showcase` from the sample frames that `preview` produces.
// Paths are root-relative (compiled with --root at the repo root).
#set page(width: 660pt, height: 565pt, margin: (x: 22pt, top: 20pt, bottom: 16pt), fill: rgb("#FFFFFF"))
#set text(font: "Source Sans 3", fill: rgb("#1F2937"))
#align(center)[
  #text(size: 15pt, weight: 700)[The cover is optional.]
  #v(2pt)
  #text(size: 10pt, fill: rgb("#6B7280"))[By default the first page opens with a masthead. Add --cover for a calm, light title page.]
]
#v(11pt)
#grid(columns: (1fr, 1fr), gutter: 18pt,
  ..(("/docs/images/sample-nocover.png", "default — masthead, no cover"),
     ("/docs/images/sample-cover-logo.png", "--cover (light)")).map(it => {
    block(radius: 6pt, clip: true, stroke: 0.5pt + rgb("#E5E7EB"), image(it.at(0), width: 100%))
    v(5pt)
    align(center, text(size: 9pt, fill: rgb("#6B7280"))[#it.at(1)])
  })
)
