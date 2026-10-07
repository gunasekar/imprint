PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

# Where Claude Code looks for user skills (override with SKILLDIR=...).
SKILLDIR ?= $(HOME)/.claude/skills

.PHONY: install uninstall skill uninstall-skill check lint-md example readme config profile preview showcase \
        quarto-sync quarto-check quarto-fixture quarto-example

# The Quarto format extension. It renders from the same template as the CLI, but
# `quarto add` installs _extensions/imprint/ and nothing outside it, so the shared
# files have to physically live inside the extension. They are byte-identical copies,
# refreshed by `quarto-sync` and policed by `quarto-check` — not symlinks, because
# Quarto copies a symlink as a symlink and it dangles on the user's machine.
QUARTO_EXT := quarto/_extensions/imprint

## Symlink imprint onto your PATH (override with PREFIX=~/.local)
install:
	@mkdir -p "$(BINDIR)"
	@ln -sf "$(CURDIR)/imprint" "$(BINDIR)/imprint"
	@echo "linked $(BINDIR)/imprint -> $(CURDIR)/imprint"
	@echo "checking prerequisites:"
	@$(MAKE) --no-print-directory check

uninstall:
	@rm -f "$(BINDIR)/imprint"
	@echo "removed $(BINDIR)/imprint"

## Scaffold a user config at ~/.config/imprint/config.yaml from the example
config:
	@mkdir -p "$(HOME)/.config/imprint"
	@if [ -f "$(HOME)/.config/imprint/config.yaml" ]; then \
	  echo "exists: $(HOME)/.config/imprint/config.yaml (left untouched)"; \
	else \
	  cp "$(CURDIR)/config.example.yaml" "$(HOME)/.config/imprint/config.yaml"; \
	  echo "created $(HOME)/.config/imprint/config.yaml — edit it with your name and accent"; \
	fi

## Scaffold a per-org/house-style profile: make profile NAME=acme
## -> ~/.config/imprint/profiles/acme.yaml (select it with `imprint --profile acme`)
profile:
	@if [ -z "$(NAME)" ]; then echo "usage: make profile NAME=<name>   (e.g. NAME=acme)"; exit 2; fi
	@mkdir -p "$(HOME)/.config/imprint/profiles"
	@if [ -f "$(HOME)/.config/imprint/profiles/$(NAME).yaml" ]; then \
	  echo "exists: $(HOME)/.config/imprint/profiles/$(NAME).yaml (left untouched)"; \
	else \
	  cp "$(CURDIR)/config.example.yaml" "$(HOME)/.config/imprint/profiles/$(NAME).yaml"; \
	  echo "created $(HOME)/.config/imprint/profiles/$(NAME).yaml — set its accent, fonts, and logo"; \
	  echo "put $(NAME)'s logo beside it, then: imprint doc.md --profile $(NAME)"; \
	fi

## Install the /imprint Claude Code skill from this clone (symlink; override with
## SKILLDIR=...). The curl installer links it automatically when Claude Code is present.
skill:
	@mkdir -p "$(SKILLDIR)"
	@ln -sfn "$(CURDIR)/skills/imprint" "$(SKILLDIR)/imprint"
	@echo "linked $(SKILLDIR)/imprint -> $(CURDIR)/skills/imprint"
	@echo "open Claude Code and type /imprint <path/to/source.md>"

uninstall-skill:
	@rm -f "$(SKILLDIR)/imprint"
	@echo "removed $(SKILLDIR)/imprint"

## Refresh the Quarto extension's copies of the shared template and fonts
quarto-sync:
	@cp templates/typst-template.typ templates/typst-show.typ "$(QUARTO_EXT)/"
	@rm -rf "$(QUARTO_EXT)/fonts"
	@mkdir -p "$(QUARTO_EXT)/fonts"
	@cp -R assets/fonts/. "$(QUARTO_EXT)/fonts/"
	@echo "synced $(QUARTO_EXT) <- templates/{typst-template,typst-show}.typ + assets/fonts/"

## Fail if the extension's copies have drifted from their sources (CI runs this)
quarto-check:
	@cmp -s templates/typst-template.typ "$(QUARTO_EXT)/typst-template.typ" \
	  && cmp -s templates/typst-show.typ "$(QUARTO_EXT)/typst-show.typ" \
	  && diff -rq assets/fonts "$(QUARTO_EXT)/fonts" >/dev/null \
	  || { echo "stale: the Quarto extension has drifted from its sources — run 'make quarto-sync'"; exit 1; }
	@echo "ok   quarto extension is in sync with templates/ and assets/fonts/"

## Render the Mermaid-free Quarto fixture (what CI runs; needs quarto)
quarto-fixture:
	@rm -rf .tmp/quarto-ci && mkdir -p .tmp/quarto-ci/_extensions
	@cp -R "$(QUARTO_EXT)" .tmp/quarto-ci/_extensions/
	@cp tests/quarto-fixture.qmd examples/logo.svg .tmp/quarto-ci/
	cd .tmp/quarto-ci && quarto render quarto-fixture.qmd --to imprint-typst
	@test -s .tmp/quarto-ci/quarto-fixture.pdf
	@head -c4 .tmp/quarto-ci/quarto-fixture.pdf | grep -q '%PDF'
	@echo "ok   rendered $$(wc -c < .tmp/quarto-ci/quarto-fixture.pdf | tr -d ' ') bytes"

## Render quarto/example.qmd in place (needs quarto, and Chromium for its Mermaid
## block). quarto/ is a working Quarto project — the extension sits in its _extensions,
## so the example renders against it with no staging.
quarto-example:
	cd quarto && quarto render example.qmd --to imprint-typst
	@echo "wrote quarto/example.pdf"

## Lint the Markdown docs (rules + globs in .markdownlint-cli2.yaml; needs node/npx)
lint-md:
	npx --yes markdownlint-cli2

## Verify required tools are present
check:
	@if [ -n "$${SUDO_USER:-}" ]; then \
	  for t in pandoc python3 typst; do \
	    su - "$$SUDO_USER" -c "command -v $$t" >/dev/null 2>&1 && echo "ok   $$t" || echo "MISS $$t (required)"; \
	  done; \
	  su - "$$SUDO_USER" -c "command -v mmdc" >/dev/null 2>&1 && echo "ok   mmdc" || echo "warn mmdc (needed for Mermaid diagrams)"; \
	else \
	  for t in pandoc python3 typst; do \
	    command -v $$t >/dev/null 2>&1 && echo "ok   $$t" || echo "MISS $$t (required)"; done; \
	  command -v mmdc >/dev/null 2>&1 && echo "ok   mmdc" || echo "warn mmdc (needed for Mermaid diagrams)"; \
	fi

## Render this README to README.pdf. Its metadata comes from flags, not front matter:
## a YAML fence would render as a metadata table at the top of the GitHub landing
## page, and the README is read on github.com far more often than it is typeset.
readme:
	./imprint README.md -o README.pdf \
	  --title "imprint" \
	  --subtitle "Branded, typeset documents from Markdown" \
	  --desc "Turn a Markdown file into a branded, typeset PDF — cover page, running header and footer, and a reusable house style — with one command." \
	  --category "Documentation"

## Render the bundled sample (metadata comes from its front matter)
example:
	./imprint examples/sample.md -o examples/sample.pdf
	@echo "wrote examples/sample.pdf"

## Render the bundled sample in all its variants to docs/images/sample-*.png — the
## masthead and three cover styles, plus a body and diagram page. `make showcase`
## composites four of these into the README strips. Needs pdftoppm (poppler) and
## magick (ImageMagick).
preview:
	@mkdir -p docs/images .tmp/preview
	./imprint examples/sample.md --no-cover --no-confidential -o .tmp/preview/nocover.pdf
	./imprint examples/sample.md --cover --no-gradient --no-logo --no-confidential -o .tmp/preview/cover.pdf
	./imprint examples/sample.md --cover --no-gradient --logo logo.svg --no-confidential -o .tmp/preview/coverlogo.pdf
	./imprint examples/sample.md --cover --gradient --logo logo.svg --logo-dark-bg logo-dark-bg.svg --no-confidential -o .tmp/preview/gradient.pdf
	@# cover variants — page 1 of each (pair = "src outname")
	@for pair in "nocover nocover" "cover cover" "coverlogo cover-logo" "gradient cover-logo-gradient"; do \
	  set -- $$pair; \
	  pdftoppm -png -r 150 -f 1 -l 1 ".tmp/preview/$$1.pdf" ".tmp/preview/$$1-c"; \
	  magick ".tmp/preview/$$1-c-1.png" -resize 900x -bordercolor '#D8DBE0' -border 1 -strip "docs/images/sample-$$2.png"; \
	done
	@# body (page 2) and diagram (page 3), from the cover+logo render
	@pdftoppm -png -r 150 -f 2 -l 3 .tmp/preview/coverlogo.pdf .tmp/preview/cl
	@magick .tmp/preview/cl-2.png -resize 900x -bordercolor '#D8DBE0' -border 1 -strip docs/images/sample-body.png
	@magick .tmp/preview/cl-3.png -resize 900x -bordercolor '#D8DBE0' -border 1 -strip docs/images/sample-diagram.png
	@echo "wrote docs/images/sample-{nocover,cover,cover-logo,cover-logo-gradient,body,diagram}.png"

## Rebuild the three captioned README showcase strips (docs/images/showcase-*.png)
## from examples/sample.md, the org logos in docs/showcase/, and the sample frames
## from `preview`. Composited with Typst. Needs pdftoppm (poppler) and typst.
showcase: preview
	@mkdir -p .tmp/showcase
	@# one gradient cover per org — its own logo + accent (page 1). sample.md sets
	@# confidential: true, so each cover keeps its CONFIDENTIAL marker.
	./imprint examples/sample.md --cover --gradient --logo-dark-bg docs/showcase/acme.svg     --accent '#2563EB' -o .tmp/showcase/acme.pdf
	./imprint examples/sample.md --cover --gradient --logo-dark-bg docs/showcase/contoso.svg  --accent '#0D9488' -o .tmp/showcase/contoso.pdf
	./imprint examples/sample.md --cover --gradient --logo-dark-bg docs/showcase/fabrikam.svg --accent '#B91C1C' -o .tmp/showcase/fabrikam.pdf
	@for o in acme contoso fabrikam; do pdftoppm -png -singlefile -r 150 -f 1 -l 1 ".tmp/showcase/$$o.pdf" ".tmp/showcase/$$o"; done
	@# compose the captioned strips (--root lets the scripts read /docs and /.tmp)
	typst compile docs/showcase/profiles.typ docs/images/showcase-profiles.png --root "$(CURDIR)" --font-path assets/fonts --ignore-system-fonts --ppi 200
	typst compile docs/showcase/covers.typ   docs/images/showcase-covers.png   --root "$(CURDIR)" --font-path assets/fonts --ignore-system-fonts --ppi 200
	typst compile docs/showcase/interior.typ docs/images/showcase-interior.png --root "$(CURDIR)" --font-path assets/fonts --ignore-system-fonts --ppi 200
	@echo "wrote docs/images/showcase-{profiles,covers,interior}.png"
