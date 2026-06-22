PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

# Where Claude Code looks for user skills (override with SKILLDIR=...).
SKILLDIR ?= $(HOME)/.claude/skills

.PHONY: install uninstall skill uninstall-skill check lint-md example config profile preview showcase

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

## Lint the Markdown docs (rules + globs in .markdownlint-cli2.yaml; needs node/npx)
lint-md:
	npx --yes markdownlint-cli2

## Verify required tools are present
check:
	@for t in pandoc python3 typst; do \
	  command -v $$t >/dev/null && echo "ok   $$t" || echo "MISS $$t (required)"; done
	@command -v mmdc >/dev/null && echo "ok   mmdc" || echo "warn mmdc (needed for Mermaid diagrams)"

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
