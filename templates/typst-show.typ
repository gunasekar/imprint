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
