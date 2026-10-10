# Dotfiles

Personal configuration files for Claude Code, shell, and development tools. Designed for easy syncing across personal and work setups.

## What's Included

- **zsh/** - Shell configuration (.zshrc)
- **claude/** - Claude Code settings and custom sounds
  - `settings.json` - Claude Code configuration (permissions, plugins, sound hooks)
  - `commands/` - Custom Claude Code commands
  - `skills/` - Custom Claude Code skills
  - `sounds/` - Audio files and the `play_*.sh` scripts the hooks call

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

## Settings Merge

If `~/.claude/settings.json` already exists, `install.sh` merges the dotfiles settings into it instead of overwriting it. It shows a diff and asks for confirmation before writing (a `settings.json.bak` backup is saved first). Runs without a terminal never change an existing file. The merge requires `jq`.

- Local values win for scalar settings such as `model` and `defaultMode`.
- Lists such as permissions keep local entries and add any missing dotfiles entries.
- Each hook event defined in the dotfiles replaces the local one, so stale hook commands do not play duplicate sounds. Hook events that exist only locally are kept.

## Sound Configuration

Hooks call small scripts in `~/.claude/sounds` that play a sound unless `CLAUDE_MUTE_SOUNDS` is set:

| Script | Played when |
| --- | --- |
| `play_permission_sound.sh` | Claude asks permission to use a tool. |
| `play_question_sound.sh` | Claude asks you a question, exits plan mode, or an agent needs input. |
| `play_stop_sound.sh` | Claude finishes responding. |
| `play_error_sound.sh` | A turn ends because of an API error. |

Each script is a one-liner that names a sound file and passes it to the shared `play_sound.sh` helper. To change a sound, edit the file name in the matching script.

The `PermissionRequest` hook excludes `AskUserQuestion` and `ExitPlanMode` so the permission sound does not play alongside the question sound.

To silence sounds temporarily:
```bash
export CLAUDE_MUTE_SOUNDS=1
```

Sounds and scripts are installed as real copies, not symlinks. If a local copy differs from the dotfiles version, `install.sh` shows the difference and asks before overwriting. `uninstall.sh` removes copies that are still identical to the dotfiles version and keeps any you edited.

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
        ├── play_sound.sh
        ├── play_permission_sound.sh
        ├── play_question_sound.sh
        ├── play_stop_sound.sh
        ├── play_error_sound.sh
        └── *.mp3
```
