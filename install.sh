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

MARKER_START="# === DOTFILES MANAGED SECTION START ==="
MARKER_END="# === DOTFILES MANAGED SECTION END ==="

# Ask a yes/no question. Defaults to "no", and also answers "no" when stdin is
# not a terminal so unattended runs never change existing files.
confirm() {
    local reply
    if [ ! -t 0 ]; then
        return 1
    fi
    read -r -p "$1 [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]]
}

# Copy a file as a real file (never a symlink).
#   - Missing destination: copy it.
#   - Symlink destination (left by older installs): replace it with a copy.
#   - Identical destination: do nothing.
#   - Different destination: show the diff and ask before overwriting.
copy_file() {
    local src="$1" dst="$2"

    if [ -L "$dst" ]; then
        rm -f "$dst"
    fi

    if [ ! -e "$dst" ]; then
        cp "$src" "$dst"
        return 0
    fi

    if cmp -s "$src" "$dst"; then
        return 0
    fi

    echo "⚠️  $dst differs from the dotfiles copy."
    if [[ "$src" == *.mp3 ]]; then
        echo "   (binary file, no diff shown)"
    else
        diff -u "$dst" "$src" || true
    fi
    if confirm "Overwrite $dst?"; then
        cp "$src" "$dst"
    else
        echo "   Kept local $dst"
    fi
}

# Merge the dotfiles settings.json into an existing ~/.claude/settings.json.
# Local values win for scalars, arrays keep local entries and add any missing
# dotfiles entries, and objects are merged recursively. The exception is hooks:
# each hook event defined by the dotfiles replaces the local one (merging hook
# groups would leave stale commands behind and play duplicate sounds), while
# hook events that only exist locally are kept. The diff is shown and the file
# is only written after confirmation (a backup is saved first).
merge_settings() {
    local src="$1" dst="$2" merged

    if ! command -v jq >/dev/null 2>&1; then
        echo "⚠️  jq not found. Skipping settings.json merge (brew install jq)."
        return 0
    fi

    merged="$(mktemp)"

    if ! jq -n --slurpfile local "$dst" --slurpfile repo "$src" '
        def merge($a; $b):
            if ($a | type) == "object" and ($b | type) == "object" then
                reduce ($b | keys_unsorted[]) as $k ($a;
                    .[$k] = (if has($k) then merge(.[$k]; $b[$k]) else $b[$k] end))
            elif ($a | type) == "array" and ($b | type) == "array" then
                $a + ($b - $a)
            else
                $a
            end;
        merge($local[0]; $repo[0])
        | .hooks = (($local[0].hooks // {}) + ($repo[0].hooks // {}))
    ' > "$merged"; then
        echo "⚠️  Could not merge settings.json (is ~/.claude/settings.json valid JSON?). Skipping."
        rm -f "$merged"
        return 0
    fi

    if diff -q "$dst" "$merged" >/dev/null; then
        echo "✓ ~/.claude/settings.json already contains the dotfiles settings"
        rm -f "$merged"
        return 0
    fi

    echo "📋 Merging dotfiles settings into ~/.claude/settings.json. Changes:"
    diff -u "$dst" "$merged" || true
    if confirm "Apply these changes to $dst?"; then
        cp "$dst" "$dst.bak"
        cp "$merged" "$dst"
        echo "✓ settings.json merged (backup saved as $dst.bak)"
    else
        echo "✓ settings.json left unchanged"
    fi
    rm -f "$merged"
}

# Create directories if needed
mkdir -p ~/.zsh

if [ "$INSTALL_ZSH" = true ]; then
    # Merge zsh config
    echo "🔗 Merging .zshrc..."

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

    mkdir -p ~/.agents

    if [ -f ~/.agents/AGENTS.md ]; then
        # Check if already merged
        if grep -q "$MARKER_START" ~/.agents/AGENTS.md; then
            # Remove old managed section
            sed -i.bak "/^$MARKER_START/,/^$MARKER_END/d" ~/.agents/AGENTS.md
        fi
    else
        touch ~/.agents/AGENTS.md
    fi

    # Append dotfiles AGENTS.md with markers
    {
        echo ""
        echo "$MARKER_START"
        cat "$DOTFILES/bin/agents/AGENTS.md"
        echo ""
        echo "$MARKER_END"
    } >> ~/.agents/AGENTS.md

    echo "✓ AGENTS.md merged (local edits preserved)"
fi

if [ "$INSTALL_CLAUDE" = true ]; then
    # Merge CLAUDE.md
    echo "🔗 Merging CLAUDE.md..."

    mkdir -p ~/.claude

    if [ -f ~/.claude/CLAUDE.md ]; then
        # Check if already merged
        if grep -q "$MARKER_START" ~/.claude/CLAUDE.md; then
            # Remove old managed section
            sed -i.bak "/^$MARKER_START/,/^$MARKER_END/d" ~/.claude/CLAUDE.md
        fi
    else
        touch ~/.claude/CLAUDE.md
    fi

    # Append dotfiles CLAUDE.md with markers
    {
        echo ""
        echo "$MARKER_START"
        cat "$DOTFILES/bin/claude/CLAUDE.md"
        echo ""
        echo "$MARKER_END"
    } >> ~/.claude/CLAUDE.md

    echo "✓ CLAUDE.md merged (local edits preserved)"
fi

if [ "$INSTALL_CLAUDE" = true ]; then
    # Setup Claude Code config
    echo "📋 Setting up Claude Code config..."

    mkdir -p ~/.claude/{commands,skills,sounds}

    # Create settings.json, or merge into the existing one
    if [ -f ~/.claude/settings.json ]; then
        merge_settings "$DOTFILES/bin/claude/settings.json" ~/.claude/settings.json
    else
        echo "📋 Creating ~/.claude/settings.json from dotfiles..."
        cp "$DOTFILES/bin/claude/settings.json" ~/.claude/settings.json
    fi

    # Copy statusline script only if it doesn't exist
    if [ -f ~/.claude/statusline-command.sh ]; then
        echo "✓ ~/.claude/statusline-command.sh exists (preserving local edits)"
    else
        echo "📋 Creating ~/.claude/statusline-command.sh from dotfiles..."
        cp "$DOTFILES/bin/claude/statusline-command.sh" ~/.claude/statusline-command.sh
    fi

    # Sounds and their play_*.sh scripts are real copies, not symlinks
    for file in "$DOTFILES/bin/claude/sounds"/*; do
        if [ -f "$file" ]; then
            copy_file "$file" ~/.claude/sounds/"$(basename "$file")"
        fi
    done

    # Link individual files for easy uninstallation
    for dir in commands skills; do
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

    echo "✓ Claude Code config setup complete (sounds copied, commands and skills linked individually)"
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
