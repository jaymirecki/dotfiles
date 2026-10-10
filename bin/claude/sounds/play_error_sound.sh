#!/bin/bash
# Played when a turn ends because of an API error (StopFailure).
# To change the sound, edit the file name below.
exec "$(dirname "$0")/play_sound.sh" han_bad_feeling.mp3
