#!/bin/bash

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default: install both
INSTALL_ZSH=true
INSTALL_CLAUDE=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --zsh-only)
            INSTALL_CLAUDE=false
            shift
            ;;
        --claude-only)
            INSTALL_ZSH=false
            shift
            ;;
        --help)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --zsh-only      Install only .zshrc configuration"
            echo "  --claude-only   Install only Claude Code configuration"
            echo "  --help          Show this help message"
            echo ""
            echo "By default, both .zshrc and Claude Code config are installed."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "🚀 Setting up dotfiles..."

# Create directories if needed
mkdir -p ~/.zsh

if [ "$INSTALL_ZSH" = true ]; then
    # Merge zsh config
    echo "🔗 Merging .zshrc..."

    MARKER_START="# === DOTFILES MANAGED SECTION START ==="
    MARKER_END="# === DOTFILES MANAGED SECTION END ==="

    if [ -f ~/.zshrc ]; then
        # Check if already merged
        if grep -q "$MARKER_START" ~/.zshrc; then
            # Remove old managed section
            sed -i.bak "/^$MARKER_START/,/^$MARKER_END/d" ~/.zshrc
        fi
    else
        touch ~/.zshrc
    fi

    # Append dotfiles zshrc with markers
    {
        echo ""
        echo "$MARKER_START"
        cat "$DOTFILES/bin/zsh/.zshrc"
        echo "$MARKER_END"
    } >> ~/.zshrc

    echo "✓ .zshrc merged (local edits preserved)"
fi

if [ "$INSTALL_CLAUDE" = true ]; then
    # Merge AGENTS.md
    echo "🔗 Merging AGENTS.md..."

    AGENTS_MARKER_START="# === DOTFILES MANAGED SECTION START ==="
    AGENTS_MARKER_END="# === DOTFILES MANAGED SECTION END ==="

    mkdir -p ~/.agents

    if [ -f ~/.agents/AGENTS.md ]; then
        # Check if already merged
        if grep -q "$AGENTS_MARKER_START" ~/.agents/AGENTS.md; then
            # Remove old managed section
            sed -i.bak "/^$AGENTS_MARKER_START/,/^$AGENTS_MARKER_END/d" ~/.agents/AGENTS.md
        fi
    else
        touch ~/.agents/AGENTS.md
    fi

    # Append dotfiles AGENTS.md with markers
    {
        echo ""
        echo "$AGENTS_MARKER_START"
        cat "$DOTFILES/bin/agents/AGENTS.md"
        echo "$AGENTS_MARKER_END"
    } >> ~/.agents/AGENTS.md

    echo "✓ AGENTS.md merged (local edits preserved)"
fi

if [ "$INSTALL_CLAUDE" = true ]; then
    # Setup Claude Code config
    echo "📋 Setting up Claude Code config..."

    mkdir -p ~/.claude/{commands,skills,sounds}

    # Copy settings.json only if it doesn't exist
    if [ -f ~/.claude/settings.json ]; then
        echo "✓ ~/.claude/settings.json exists (preserving local edits)"
    else
        echo "📋 Creating ~/.claude/settings.json from dotfiles..."
        cp "$DOTFILES/bin/claude/settings.json" ~/.claude/settings.json
    fi

    # Link statusline script
    ln -sf "$DOTFILES/bin/claude/statusline-command.sh" ~/.claude/statusline-command.sh

    # Link individual files for easy uninstallation
    for dir in commands skills sounds; do
        mkdir -p ~/.claude/$dir

        # Link each file individually
        for file in "$DOTFILES/bin/claude/$dir"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                filepath=~/.claude/$dir/$filename

                # Remove existing link/file and create new link
                rm -f "$filepath"
                ln -sf "$file" "$filepath"
            fi
        done
    done

    echo "✓ Claude Code config setup complete (dotfile-managed files linked individually)"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Reload your shell: source ~/.zshrc"
if [ "$INSTALL_CLAUDE" = true ]; then
    echo "2. Review Claude Code settings: ~/.claude/settings.json"
fi
echo ""
