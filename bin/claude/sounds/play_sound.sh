#!/bin/bash
# Shared helper for Claude Code hook sounds.
#
# Usage: play_sound.sh <sound-file>
#
# <sound-file> is resolved relative to this script's directory unless it is
# an absolute path. Does nothing when CLAUDE_MUTE_SOUNDS is set and non-empty.
# Always exits 0 so a missing file or audio failure never breaks a hook.

[ -n "$CLAUDE_MUTE_SOUNDS" ] && exit 0

sound="$1"
[ -z "$sound" ] && exit 0

# Resolve relative names against the directory containing this script.
case "$sound" in
    /*) ;;
    *) sound="$(cd "$(dirname "$0")" && pwd)/$sound" ;;
esac

afplay "$sound" 2>/dev/null || true
exit 0
