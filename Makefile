PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

# Where Claude Code looks for user slash commands (override with CMDDIR=...).
CMDDIR ?= $(HOME)/.claude/commands

.PHONY: install uninstall command uninstall-command check example config preview

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

## Install the /imprint Claude Code slash command (symlink; override with CMDDIR=...)
command:
	@mkdir -p "$(CMDDIR)"
	@ln -sfn "$(CURDIR)/commands/imprint.md" "$(CMDDIR)/imprint.md"
	@echo "linked $(CMDDIR)/imprint.md -> $(CURDIR)/commands/imprint.md"
	@echo "open Claude Code and type /imprint <path/to/source.md>"

uninstall-command:
	@rm -f "$(CMDDIR)/imprint.md"
	@echo "removed $(CMDDIR)/imprint.md"

## Verify required tools are present
check:
	@for t in pandoc python3 typst; do \
	  command -v $$t >/dev/null && echo "ok   $$t" || echo "MISS $$t (required)"; done
	@command -v mmdc >/dev/null && echo "ok   mmdc" || echo "warn mmdc (needed for Mermaid diagrams)"

## Render the bundled sample (metadata comes from its front matter)
example:
	./imprint examples/sample.md -o examples/sample.pdf
	@echo "wrote examples/sample.pdf"

## Regenerate the README snapshot grid (docs/images/) from examples/sample.md.
## Needs pdftoppm (poppler) and magick (ImageMagick) in addition to imprint.
preview:
	@mkdir -p docs/images .tmp/preview
	./imprint examples/sample.md -o .tmp/preview/minimal.pdf
	./imprint examples/sample.md --recipient "Acme Corp" --category "Documentation" \
	  --confidential --logo logo.svg -o .tmp/preview/full.pdf
	./imprint examples/sample.md --recipient "Acme Corp" --category "Documentation" \
	  --confidential --gradient --logo-dark-bg logo-dark-bg.svg -o .tmp/preview/gradient.pdf
	./imprint examples/sample.md --no-cover -o .tmp/preview/nocover.pdf
	@for v in minimal full; do \
	  pdftoppm -png -r 150 ".tmp/preview/$$v.pdf" ".tmp/preview/$$v"; \
	  for p in 1 2 3; do \
	    magick ".tmp/preview/$$v-$$p.png" -resize 900x \
	      -bordercolor '#D8DBE0' -border 1 -strip "docs/images/sample-$$v-$$p.png"; \
	  done; \
	done
	@for v in gradient nocover; do \
	  pdftoppm -png -r 150 -f 1 -l 1 ".tmp/preview/$$v.pdf" ".tmp/preview/$$v"; \
	  magick ".tmp/preview/$$v-1.png" -resize 900x \
	    -bordercolor '#D8DBE0' -border 1 -strip "docs/images/sample-$$v-1.png"; \
	done
	@echo "wrote docs/images/sample-{minimal,full}-{1,2,3}.png + sample-{gradient,nocover}-1.png"
