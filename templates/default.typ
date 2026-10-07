// imprint's default pandoc->Typst template — the CLI's entry point.
//
// The look itself is NOT here. It lives in the two partials below:
//
//   typst-template.typ  theme tokens + the conf() layout function (the look)
//   typst-show.typ      document metadata -> conf(...) call
//
$typst-template.typ()$

$typst-show.typ()$

$body$
