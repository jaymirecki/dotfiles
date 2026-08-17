# Dotfiles

Personal configuration files for Claude Code, shell, and development tools. Designed for easy syncing across personal and work setups.

## What's Included

- **zsh/** - Shell configuration (.zshrc)
- **claude/** - Claude Code settings and custom sounds
  - `settings.json` - Claude Code configuration with R2D2 sound hooks
  - `commands/` - Custom Claude Code commands
  - `skills/` - Custom Claude Code skills
  - `sounds/` - R2D2 audio files for notifications

## Quick Setup

```bash
cd ~/dotfiles
./install.sh
```

For component-specific installation:

```bash
./install.sh --zsh-only      # Install only shell config
./install.sh --claude-only   # Install only Claude Code config
```

## Sound Configuration

The Claude Code settings include R2D2 sounds for:
- Task completion
- Permission requests
- Notifications
- Waiting for input

To silence sounds temporarily:
```bash
export CLAUDE_MUTE_SOUNDS=1
```

## Git LFS

Audio files (.mp3) are tracked with Git LFS. Make sure Git LFS is installed:

```bash
brew install git-lfs
git lfs install
```

## Machine-Specific Setup

For personal vs. work setups, edit `claude/settings.json` after running install.sh to customize for your specific machine.

## Structure

```
dotfiles/
├── README.md
├── install.sh
├── .gitignore
├── .gitattributes
├── zsh/
│   └── .zshrc
└── claude/
    ├── settings.json
    ├── commands/
    ├── skills/
    └── sounds/
        ├── r2d2_beepbeepboop.mp3
        ├── r2d2_beepbooweep.mp3
        ├── r2d2_bewer.mp3
        ├── r2d2_brrwzzrr.mp3
        └── r2d2_thbt.mp3
```
