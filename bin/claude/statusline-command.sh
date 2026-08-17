#!/bin/bash
# Claude Code statusline
# Line 1: model name, context window usage (used %% / remaining %%)
# Line 2: workspace (project) directory, repo, branch, current working directory

format_remaining_time() {
  local reset_epoch=$1
  local now=$(date +%s)
  local remaining=$((reset_epoch - now))

  if [ $remaining -le 0 ]; then
    echo "0m"
    return
  fi

  local days=$((remaining / 86400))
  local hours=$(((remaining % 86400) / 3600))
  local minutes=$(((remaining % 3600) / 60))

  local result=""
  if [ $days -gt 0 ]; then
    result="${days}d"
  fi
  if [ $hours -gt 0 ]; then
    [ -n "$result" ] && result="${result} "
    result="${result}${hours}h"
  fi
  if [ $minutes -gt 0 ] || [ -z "$result" ]; then
    [ -n "$result" ] && result="${result} "
    result="${result}${minutes}m"
  fi

  echo "$result"
}

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour_used=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset_time=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_used=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset_time=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

workspace_dir=$(echo "$input" | jq -r '.workspace.project_dir')
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')

branch=""
if [ -n "$cwd" ]; then
  branch=$(git --no-optional-locks -C "$cwd" branch --show-current 2>/dev/null)
fi

DIM=$'\033[2m'
RESET=$'\033[0m'
CYAN=$'\033[2;36m'

# Line 1: model + context usage + rate limits
line1="${CYAN}${model}${RESET}"
if [ -n "$context_used" ]; then
  context_used_r=$(printf '%.0f' "$context_used")
  line1="${line1}${DIM} | Context: ${context_used_r}%${RESET}"
fi
if [ -n "$five_hour_used" ] && [ -n "$five_hour_reset_time" ]; then
  five_hour_used_r=$(printf '%.0f' "$five_hour_used")
  five_hour_remaining=$(format_remaining_time "$five_hour_reset_time")
  line1="${line1}${DIM} | 5h: ${five_hour_used_r}% - ${five_hour_remaining}${RESET}"

fi
if [ -n "$week_used" ] && [ -n "$week_reset_time" ]; then
  week_used_r=$(printf '%.0f' "$week_used")
  week_remaining=$(format_remaining_time "$week_reset_time")
  line1="${line1}${DIM} | 7d: ${week_used_r}% - ${week_remaining}${RESET}"
fi

# Line 2: workspace dir, repo, branch, cwd
workspace_dir_name=$(basename "$workspace_dir")
cwd_name=$(basename "$cwd")
line2="${DIM}${workspace_dir_name}"
if [ -n "$repo" ]; then
  line2="${line2} | ${repo}"
fi
if [ -n "$branch" ]; then
  line2="${line2} | ${branch}"
fi
line2="${line2} | ${cwd_name}${RESET}"

printf "%s\n%s\n" "$line1" "$line2"
