#!/bin/sh
set -eu

SOURCE_URL="https://raw.githubusercontent.com/Sl0oth/claude-menu/main/clm"
BIN_DIR="${CLM_BIN_DIR:-$HOME/.local/bin}"
BIN_DIR="${BIN_DIR%/}"
TARGET="$BIN_DIR/clm"

say() { printf '%s\n' "$*"; }
fail() { printf 'clm install: %s\n' "$*" >&2; exit 1; }

if [ "${1:-}" = "--uninstall" ]; then
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        rm -f "$TARGET"
        say "Removed $TARGET"
    else
        say "clm is not installed in $BIN_DIR"
    fi
    exit 0
fi

command -v python3 >/dev/null 2>&1 || fail "python3 is required."
python3 -c "import sys; sys.exit(sys.version_info < (3, 9))" || fail "clm needs Python 3.9 or newer."
python3 -c "import curses" 2>/dev/null || fail "your python3 is missing the curses module."

mkdir -p "$BIN_DIR"
case "$0" in
    *install.sh)
        SOURCE="$(cd "$(dirname "$0")" && pwd)/clm"
        [ -f "$SOURCE" ] || fail "no clm next to install.sh."
        chmod +x "$SOURCE"
        ;;
    *)
        command -v curl >/dev/null 2>&1 || fail "curl is required."
        SOURCE="$(mktemp)"
        trap 'rm -f "$SOURCE"' EXIT
        curl -fsSL "$SOURCE_URL" -o "$SOURCE" || fail "could not download clm."
        head -n 1 "$SOURCE" | grep -q python3 || fail "download did not look like clm."
        chmod 755 "$SOURCE"
        ;;
esac

if [ -e "$TARGET" ] && [ ! -L "$TARGET" ] && ! grep -qs "Sl0oth/claude-menu" "$TARGET"; then
    [ -e "$TARGET.bak" ] && fail "$TARGET is not clm and $TARGET.bak already exists. Move one of them and run this again."
    mv "$TARGET" "$TARGET.bak"
    say "Moved your existing $TARGET to $TARGET.bak"
fi
case "$0" in
    *install.sh)
        ln -sfn "$SOURCE" "$TARGET"
        say "Linked $TARGET -> $SOURCE"
        ;;
    *)
        rm -f "$TARGET"
        mv "$SOURCE" "$TARGET"
        say "Installed $TARGET"
        ;;
esac

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *)
        case "${SHELL##*/}" in
            zsh) RC="$HOME/.zshrc" ;;
            bash) if [ "$(uname)" = Darwin ]; then RC="$HOME/.bash_profile"; else RC="$HOME/.bashrc"; fi ;;
            fish) RC="" ;;
            *) RC="$HOME/.profile" ;;
        esac
        if [ -z "$RC" ]; then
            say "Add $BIN_DIR to your PATH: fish_add_path $BIN_DIR"
        else
            case "$BIN_DIR" in
                "$HOME"/*) SHOWN="\$HOME/${BIN_DIR#"$HOME"/}" ;;
                *) SHOWN="$BIN_DIR" ;;
            esac
            LINE="export PATH=\"$SHOWN:\$PATH\""
            grep -qsF "$LINE" "$RC" || printf '\n%s\n' "$LINE" >> "$RC"
            say "Added $BIN_DIR to your PATH in $RC. Open a new terminal or run: . $RC"
        fi
        ;;
esac

command -v claude >/dev/null 2>&1 || say "Note: Claude Code (claude) is not on your PATH yet. clm needs it to open chats."
say "Done. Run: clm"
