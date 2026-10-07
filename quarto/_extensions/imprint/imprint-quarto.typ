// Quarto-only Typst overrides. Injected via `include-in-header`, which lands after
// Quarto's definitions.typ, so a rule here wins over the one there.
//
// This file exists so the *shared* template (typst-template.typ) never has to know
// Quarto exists. Anything here is a fix for something Quarto's own preamble does that
// imprint's look does not want.

// Quarto's definitions.typ styles code blocks itself:
//     show raw.where(block: true): set block(fill: luma(230), inset: 8pt, radius: 2pt)
// imprint's template *wraps* code in its own surface block, so Quarto's fill shows
// through as a second, darker box nested inside imprint's — a visible double frame.
// Reset those properties and let imprint's block be the only one.
#show raw.where(block: true): set block(fill: none, inset: 0pt, radius: 0pt)
