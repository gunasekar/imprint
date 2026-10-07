-- imprint.lua — Lua filter for the imprint Quarto format extension.
--
-- Four things this filter does that the template alone cannot:
--
--   1. Strip the leading H1 when it duplicates the document title.
--      imprint's CLI preprocessor does this; Quarto doesn't, so without the
--      filter the title appears twice on the first body page.
--
--   2. Refuse an unparseable `date`. Quarto turns `date` into a real date and
--      renders anything it cannot parse as the literal "Invalid Date" — on the
--      cover, with no warning. Free-text dates belong in `docdate`.
--
--   3. Normalize `accent` — strip a leading '#' so users can write
--      `accent: "#2563EB"` (intuitive) and pandoc won't escape it to
--      `\#2563EB` inside the Typst template's rgb() call.
--
--   4. Frame and size Mermaid/diagram images.
--      Quarto renders Mermaid to a PNG at its natural size (~12 in wide) and
--      hard-codes that width in `#box(image(..., width: 12.67in))`.
--      A format-level `fig-width` does NOT reach Mermaid.  This filter:
--        a. Detects solo-diagram paragraphs (Para containing exactly one Image
--           whose path looks like a rendered diagram).
--        b. Replaces them with a raw-Typst `#block(...)` that matches
--           imprint's hairline-framed figure style (same inset, radius,
--           stroke, and vertical spacing as `show figure.where(kind: image)`
--           in typst-template.typ).  The `hairline` variable is defined at
--           the top level of typst-template.typ so it is in scope here.
--        c. Also handles Image nodes directly (for diagrams used inline or
--           as Quarto figure captions) by clamping their width.
--
-- Implementation note: Header is traversed BEFORE Meta in Pandoc's single-pass
-- Lua filter walk, so we cannot set a global `doc_title` in Meta and read it
-- in Header.  Instead, we use a `Pandoc`-level function that sees the whole
-- document (meta + blocks) at once and does a second block walk for H1 strip.

local FIG_WIDTH = "5.5in"   -- text column on A4 with imprint's 2.2cm side margins

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

local function is_diagram(src)
  src = src or ""
  -- Quarto writes rendered diagrams under .../figure-typst/mermaid-figure-*.png
  return src:match("mermaid") or src:match("figure%-typst") or src:match("%.mmd")
end

-- ---------------------------------------------------------------------------
-- Main filter: Pandoc-level so we can read meta before walking blocks
-- ---------------------------------------------------------------------------

function Pandoc(doc)

  -- 1. Read title --------------------------------------------------------
  local title = nil
  if doc.meta.title then
    title = pandoc.utils.stringify(doc.meta.title)
  end

  -- 2. Guard the date ----------------------------------------------------
  --    Quarto parses `date` into a real date inside its own metadata pipeline —
  --    upstream of every Lua filter — and stringifies whatever it cannot parse to
  --    the literal "Invalid Date".  By the time we see it the original text is
  --    already gone, so we cannot repair it; we can only refuse to print it.
  --    Without this, `date: "Q3 FY26"` silently ships a cover reading "Invalid
  --    Date".  `docdate` bypasses Quarto's date handling entirely (typst-show.typ
  --    prefers it), which is what imprint's free-text dates want.
  --    os.exit, not error(): Quarto catches a Lua error(), logs it, and renders the
  --    document anyway — exit 0, cover reading "Invalid Date". Killing the pandoc
  --    process is what actually stops the build and returns a failing exit code.
  if not doc.meta.docdate and doc.meta.date
     and pandoc.utils.stringify(doc.meta.date) == "Invalid Date" then
    io.stderr:write(
      "\nimprint: Quarto could not parse `date`, so the cover would read " ..
      "\"Invalid Date\".\n" ..
      "  Use `docdate:` for a free-text date  (docdate: \"Q3 FY26\")\n" ..
      "  or give `date:` a real date          (date: \"2026-06-15\")\n\n")
    os.exit(1)
  end

  -- 3. Normalize accent --------------------------------------------------
  --    Users may write `accent: "#2563EB"` (intuitive) or `accent: "2563EB"`.
  --    Pandoc escapes '#' to '\#' in Typst template variables; the template
  --    already prepends a '#' in `rgb("#$accent$")`, so any user-supplied '#'
  --    must be stripped.  We normalize here so both forms work.
  if doc.meta.accent then
    local acc = pandoc.utils.stringify(doc.meta.accent)
    acc = acc:gsub("^#", "")
    doc.meta.accent = pandoc.MetaInlines({ pandoc.Str(acc) })
  end

  -- 4. Walk blocks: H1 strip + diagram framing ---------------------------
  local h1_stripped = false

  doc.blocks = doc.blocks:walk({

    -- 4a. Strip first H1 that duplicates the document title
    Header = function(el)
      if el.level == 1 and not h1_stripped and title then
        if pandoc.utils.stringify(el) == title then
          h1_stripped = true
          return {}   -- remove the block
        end
      end
      return el
    end,

    -- 4b. Replace solo diagram paragraphs with a framed raw-Typst block.
    --     Replicates typst-template.typ's `show figure.where(kind: image)`:
    --       block(width: 100%, inset: 14pt, radius: 6pt,
    --             stroke: 0.5pt + hairline, above: 1.8em, below: 1.8em,
    --             align(center, <image>))
    --     `hairline` is defined at the top level of typst-template.typ.
    Para = function(el)
      if #el.content == 1 and el.content[1].t == "Image" then
        local img = el.content[1]
        if is_diagram(img.src) then
          local typst = string.format(
            '#block(width: 100%%, inset: 14pt, radius: 6pt, ' ..
            'stroke: 0.5pt + hairline, above: 1.8em, below: 1.8em, ' ..
            'align(center, image("%s", width: 5.5in)))',
            img.src
          )
          return pandoc.RawBlock("typst", typst)
        end
      end
      return el
    end,

    -- 4c. Clamp diagram images used inline or inside figure captions
    Image = function(img)
      if is_diagram(img.src) then
        img.attributes.width  = FIG_WIDTH
        img.attributes.height = nil   -- let height follow the aspect ratio
      end
      return img
    end,

  })

  return doc
end
