#!/usr/bin/env sh
# imprint installer — fetch the repo and symlink the CLI onto your PATH.
#
#   curl -fsSL https://raw.githubusercontent.com/gunasekar/imprint/main/install.sh | sh
#
# imprint is a script plus a Typst template and bundled fonts, so this clones the
# whole repo into a share dir and symlinks `imprint` into a bin dir. Re-running
# updates an existing install. If Claude Code is detected, it also links the
# optional /imprint skill. Override locations with env vars:
#   IMPRINT_HOME  (default ~/.local/share/imprint)   where the repo lives
#   IMPRINT_BIN   (default ~/.local/bin)            where the symlink goes
#   IMPRINT_REPO / IMPRINT_BRANCH                     source to fetch from
#   IMPRINT_SKILLDIR (default ~/.claude/skills)      Claude Code skills dir
#   IMPRINT_NO_CLAUDE_SKILL=1                          skip the /imprint skill
set -eu

REPO="${IMPRINT_REPO:-https://github.com/gunasekar/imprint}"
BRANCH="${IMPRINT_BRANCH:-main}"
HOME_DIR="${IMPRINT_HOME:-$HOME/.local/share/imprint}"
BINDIR="${IMPRINT_BIN:-$HOME/.local/bin}"

say() { printf '%s\n' "$*"; }

# --- 1. fetch or update the repo ---
clone() {
  say "cloning $REPO -> $HOME_DIR"
  mkdir -p "$(dirname "$HOME_DIR")"
  rm -rf "$HOME_DIR"
  git clone --depth 1 --branch "$BRANCH" --quiet "$REPO" "$HOME_DIR"
}

if command -v git >/dev/null 2>&1; then
  if [ -d "$HOME_DIR/.git" ]; then
    say "updating existing install in $HOME_DIR"
    # Fast-forward if we can; otherwise the local repo has diverged (local
    # edits, or upstream rewrote history) — drop it and re-clone fresh.
    if ! git -C "$HOME_DIR" pull --ff-only --quiet 2>/dev/null; then
      say "fast-forward failed (diverged history); re-cloning"
      clone
    fi
  else
    clone
  fi
else
  say "git not found; downloading tarball"
  # Extract into a clean dir so files deleted upstream don't linger as cruft.
  rm -rf "$HOME_DIR"
  mkdir -p "$HOME_DIR"
  curl -fsSL "$REPO/archive/refs/heads/$BRANCH.tar.gz" \
    | tar -xz -C "$HOME_DIR" --strip-components=1
fi

# --- 2. symlink the CLI onto PATH ---
mkdir -p "$BINDIR"
ln -sf "$HOME_DIR/imprint" "$BINDIR/imprint"
say "linked $BINDIR/imprint -> $HOME_DIR/imprint"

# --- 3. scaffold a user config (only if absent) ---
CFG="$HOME/.config/imprint/config.yaml"
if [ ! -f "$CFG" ]; then
  mkdir -p "$(dirname "$CFG")"
  cp "$HOME_DIR/config.example.yaml" "$CFG"
  say "created $CFG — edit it with your name and accent color"
fi

# --- 4. Claude Code /imprint skill (only if Claude Code is present) ---
# imprint ships an optional Claude Code skill (skills/imprint/). Link it only when
# Claude Code is detected (~/.claude exists) so non-users don't get a stray skills
# dir; an explicit IMPRINT_SKILLDIR forces it on. The symlink points at the cloned
# directory, so it tracks updates. Skip with IMPRINT_NO_CLAUDE_SKILL=1.
SKILLDIR="${IMPRINT_SKILLDIR:-$HOME/.claude/skills}"
if [ -z "${IMPRINT_NO_CLAUDE_SKILL:-}" ] && { [ -n "${IMPRINT_SKILLDIR:-}" ] || [ -d "$HOME/.claude" ]; }; then
  mkdir -p "$SKILLDIR"
  ln -sfn "$HOME_DIR/skills/imprint" "$SKILLDIR/imprint"
  say "linked $SKILLDIR/imprint -> $HOME_DIR/skills/imprint  (Claude Code /imprint)"
fi

# --- 5. prerequisite check ---
say ""
say "checking prerequisites:"
miss=0
for t in pandoc typst python3; do
  if command -v "$t" >/dev/null 2>&1; then say "  ok   $t"; else say "  MISS $t (required)"; miss=1; fi
done
if command -v mmdc >/dev/null 2>&1; then say "  ok   mmdc"; else say "  warn mmdc (only needed for Mermaid diagrams)"; fi
if [ "$miss" = 1 ]; then
  say ""
  case "$(uname -s)" in
    Darwin)
      say "install the missing tools with Homebrew:"
      say "  brew install pandoc typst        # + brew install mermaid-cli for Mermaid"
      ;;
    Linux)
      say "install the missing tools (Linux):"
      say "  pandoc : grab the latest .deb/.tar.gz from https://github.com/jgm/pandoc/releases"
      say "           (distro packages are often older than the 3.x the Typst writer needs)"
      say "  typst  : cargo install --locked typst-cli   (or a build from https://github.com/typst/typst/releases)"
      say "  mermaid: npm install -g @mermaid-js/mermaid-cli   # only for Mermaid diagrams"
      ;;
    *)
      say "install pandoc (>= 3), typst, and python3, then re-run this script."
      ;;
  esac
fi

# --- 6. PATH guidance ---
case ":$PATH:" in
  *":$BINDIR:"*) : ;;
  *)
    # Point the hint at the user's actual shell rc (bash on most Linux, zsh on macOS).
    rc="$HOME/.profile"; shrc="your shell"
    case "${SHELL:-}" in
      */zsh)  rc="$HOME/.zshrc";  shrc="zsh" ;;
      */bash) rc="$HOME/.bashrc"; shrc="bash" ;;
    esac
    say ""
    say "NOTE: $BINDIR is not on your PATH. Add it, e.g.:"
    say "  echo 'export PATH=\"$BINDIR:\$PATH\"' >> $rc && exec $shrc"
    ;;
esac

say ""
say "done. try:  imprint --help  (or)  imprint yourfile.md"
