#!/bin/bash
# Played when Claude Code asks the user a question (AskUserQuestion, ExitPlanMode,
# elicitations, agent_needs_input notifications).
# To change the sound, edit the file name below.
exec "$(dirname "$0")/play_sound.sh" chewbacca_question.mp3
