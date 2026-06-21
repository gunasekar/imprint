PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin

# Where Claude Code looks for user slash commands (override with CMDDIR=...).
CMDDIR ?= $(HOME)/.claude/commands

.PHONY: install uninstall command uninstall-command check example config

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
