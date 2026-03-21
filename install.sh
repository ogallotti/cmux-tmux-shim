#!/usr/bin/env bash
# cmux-tmux-shim installer
# Enables Claude Code agent teams split-pane mode inside cmux

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SHIM_SRC="$REPO_DIR/bin-tmux"
SHIM_DST="$HOME/.local/bin/tmux"
STATE_DIR="$HOME/.local/state/cmux-tmux-shim"

echo "cmux-tmux-shim installer"
echo "========================"
echo ""

# Check cmux
if ! command -v cmux &>/dev/null; then
    echo "Error: cmux not found. Install cmux first: https://github.com/manaflow-ai/cmux"
    exit 1
fi

# Check claude
if ! command -v claude &>/dev/null; then
    echo "Error: claude (Claude Code) not found."
    exit 1
fi

# Install shim
echo "Installing shim to $SHIM_DST..."
mkdir -p "$(dirname "$SHIM_DST")"
cp "$SHIM_SRC" "$SHIM_DST"
chmod +x "$SHIM_DST"

# Verify PATH priority
real_tmux=$(command -v tmux 2>/dev/null || echo "")
if [[ "$real_tmux" == "$SHIM_DST" ]] || [[ -z "$real_tmux" ]]; then
    echo "OK: shim is first in PATH"
else
    # Check if ~/.local/bin is in PATH at all
    if echo "$PATH" | tr ':' '\n' | grep -qF "$HOME/.local/bin"; then
        echo "WARNING: $real_tmux comes before $SHIM_DST in PATH"
        echo "Make sure ~/.local/bin is early in your PATH"
    else
        echo "WARNING: ~/.local/bin is not in PATH"
        echo "Add it to your shell config: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

# Init state
echo "Creating state directory at $STATE_DIR..."
mkdir -p "$STATE_DIR"
echo "0" > "$STATE_DIR/counter"

# Detect shell and show config instructions
echo ""
CURRENT_SHELL=$(basename "${SHELL:-/bin/bash}")

case "$CURRENT_SHELL" in
    fish)
        CONF_FILE="$REPO_DIR/shell/fish.conf"
        RC_FILE="$HOME/.config/fish/config.fish"
        MARKER="cmux-tmux-shim"
        echo "Detected shell: fish"
        echo ""
        if grep -qF "$MARKER" "$RC_FILE" 2>/dev/null; then
            echo "Config already present in $RC_FILE"
        else
            echo "Add this to $RC_FILE:"
            echo ""
            cat "$CONF_FILE"
            echo ""
            read -p "Add automatically? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "" >> "$RC_FILE"
                cat "$CONF_FILE" >> "$RC_FILE"
                echo "Added to $RC_FILE"
            fi
        fi
        ;;
    zsh)
        CONF_FILE="$REPO_DIR/shell/zsh.conf"
        RC_FILE="$HOME/.zshrc"
        MARKER="cmux-tmux-shim"
        echo "Detected shell: zsh"
        echo ""
        if grep -qF "$MARKER" "$RC_FILE" 2>/dev/null; then
            echo "Config already present in $RC_FILE"
        else
            echo "Add this to $RC_FILE:"
            echo ""
            cat "$CONF_FILE"
            echo ""
            read -p "Add automatically? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "" >> "$RC_FILE"
                cat "$CONF_FILE" >> "$RC_FILE"
                echo "Added to $RC_FILE"
            fi
        fi
        ;;
    *)
        echo "Shell '$CURRENT_SHELL' not directly supported."
        echo "Adapt shell/zsh.conf for your shell and add to your rc file."
        ;;
esac

echo ""
echo "Done! Open a new cmux tab to activate."
echo "Test: create an agent team and teammates should appear as split panes."
echo ""
echo "To uninstall: rm $SHIM_DST && rm -rf $STATE_DIR"
echo "Then remove the cmux-tmux-shim block from your shell config."
