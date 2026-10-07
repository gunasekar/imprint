// imprint's default pandoc->Typst template — the CLI's entry point.
//
// The look itself is NOT here. It lives in the two partials below, which imprint
// ships verbatim to the Quarto extension (quarto/_extensions/imprint/), so the CLI
// and the Quarto format render from the same bytes. Edit the partials, never a copy:
//
//   typst-template.typ  theme tokens + the conf() layout function (the look)
//   typst-show.typ      document metadata -> conf(...) call
//
// Quarto's own Typst template assembles those same two partial names, which is why
// the split falls exactly here. A custom template (`template:` / --template) replaces
// this file and may inline whatever it likes.
$typst-template.typ()$

$typst-show.typ()$

$body$
