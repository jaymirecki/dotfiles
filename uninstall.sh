#!/bin/bash

set -e

# Default: uninstall both
UNINSTALL_ZSH=true
UNINSTALL_CLAUDE=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --zsh-only)
            UNINSTALL_CLAUDE=false
            shift
            ;;
        --claude-only)
            UNINSTALL_ZSH=false
            shift
            ;;
        --help)
            echo "Usage: ./uninstall.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --zsh-only      Uninstall only .zshrc configuration"
            echo "  --claude-only   Uninstall only Claude Code configuration"
            echo "  --help          Show this help message"
            echo ""
            echo "By default, both .zshrc and Claude Code config are uninstalled."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🗑️  Uninstalling dotfiles..."

MARKER_START="# === DOTFILES MANAGED SECTION START ==="
MARKER_END="# === DOTFILES MANAGED SECTION END ==="

if [ "$UNINSTALL_ZSH" = true ]; then
    # Remove .zshrc managed section
    if [ -f ~/.zshrc ]; then
        if grep -q "$MARKER_START" ~/.zshrc; then
            echo "Removing dotfiles section from ~/.zshrc..."
            sed -i.bak "/^$MARKER_START/,/^$MARKER_END/d" ~/.zshrc
        fi
    fi
fi

if [ "$UNINSTALL_CLAUDE" = true ]; then
    # Remove AGENTS.md managed section
    if [ -f ~/.agents/AGENTS.md ]; then
        if grep -q "$MARKER_START" ~/.agents/AGENTS.md; then
            echo "Removing dotfiles section from ~/.agents/AGENTS.md..."
            sed -i.bak "/^$MARKER_START/,/^$MARKER_END/d" ~/.agents/AGENTS.md
        fi
    fi
fi

if [ "$UNINSTALL_CLAUDE" = true ]; then
    # Remove CLAUDE.md managed section
    if [ -f ~/.claude/CLAUDE.md ]; then
        if grep -q "$MARKER_START" ~/.claude/CLAUDE.md; then
            echo "Removing dotfiles section from ~/.claude/CLAUDE.md..."
            sed -i.bak "/^$MARKER_START/,/^$MARKER_END/d" ~/.claude/CLAUDE.md
        fi
    fi
fi

if [ "$UNINSTALL_CLAUDE" = true ]; then
    # Remove Claude Code symlinks (but preserve settings.json and local files)
    if [ -d ~/.claude ]; then
        for dir in commands skills sounds; do
            if [ -d ~/.claude/$dir ]; then
                for file in ~/.claude/$dir/*; do
                    if [ -L "$file" ]; then
                        echo "Removing symlink: $file"
                        rm "$file"
                    fi
                done
            fi
        done
    fi
fi

echo ""
echo "✅ Dotfiles uninstalled!"
echo ""
echo "Note:"
if [ "$UNINSTALL_ZSH" = true ]; then
    echo "- ~/.zshrc has been cleaned (backup saved as ~/.zshrc.bak)"
fi
if [ "$UNINSTALL_CLAUDE" = true ]; then
    echo "- ~/.claude/CLAUDE.md has been cleaned (backup saved as ~/.claude/CLAUDE.md.bak)"
    echo "- Local files in ~/.claude/commands/, skills/, and sounds/ are preserved"
    echo "- ~/.claude/settings.json and ~/.claude/statusline-command.sh are preserved (your local customizations)"
fi
echo ""
