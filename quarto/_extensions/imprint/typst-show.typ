// Document metadata -> conf(). Shared verbatim with the Quarto extension, so a few
// fields accept a second key that only Quarto sets — see typst-template.typ's accent
// and logo-path tokens for the same pattern.
//
//   docdate   Quarto parses `date` into a real date and reformats it, and prints
//             "Invalid Date" for anything it can't parse. imprint's dates are free
//             text ("Q3 FY26", "June 2026", "Draft"), so both the CLI and Quarto
//             pass that text as `docdate` (the CLI still accepts `date` as an
//             alias and folds it to `docdate` before emission).
//   by-author Quarto's structured author list; plain pandoc gives a flat `author`.
#show: doc => conf(
$if(title)$  title: [$title$],$endif$
$if(subtitle)$  subtitle: [$subtitle$],$endif$
$if(description)$  description: [$description$],$endif$
$if(docdate)$  date: [$docdate$],$else$$if(date)$  date: [$date$],$endif$$endif$
$if(recipient)$  recipient: [$recipient$],$endif$
$if(category)$  category: "$category$",$endif$
$if(confidential)$  confidential: true,$endif$
$if(cover)$  cover: true,$endif$
$if(toc)$  toc: true,$endif$
$if(numbered)$  numbered: true,$endif$
$if(footer_text)$  footer-text: [$footer_text$],$endif$
  authors: ($if(by-author)$$for(by-author)$"$by-author.name.literal$", $endfor$$else$$for(author)$"$author$", $endfor$$endif$),
  doc,
)
