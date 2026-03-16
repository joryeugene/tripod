#!/usr/bin/env bash
# Claude Code status line - compact single-line format for narrow terminals
# Receives JSON via stdin

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# Show only the directory name (basename), not the full path
if [ -n "$cwd" ]; then
  dir_name=$(basename "$cwd")
else
  dir_name="~"
fi

# Git branch (skip optional locks)
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_branch="  $branch"
  fi
fi

# Context usage - only show when >= 50% to avoid noise
ctx=""
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 90 ] 2>/dev/null; then
    ctx="  [${used_int}%!]"
  elif [ "$used_int" -ge 50 ] 2>/dev/null; then
    ctx="  [${used_int}%]"
  fi
fi

# Session short ID
session_part=""
if [ -n "$session_id" ]; then
  session_part="  #${session_id:0:8}"
fi

# Extract session slug from transcript JSONL (not exposed in statusline JSON)
session_slug=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  session_slug=$(head -3 "$transcript_path" | grep -o '"slug":"[^"]*"' | head -1 | sed 's/"slug":"//;s/"//')
fi

# Active plan for this session - plan files are named {session_slug}.md
plan_part=""
if [ -n "$session_slug" ] && [ -f "$HOME/.claude/plans/${session_slug}.md" ]; then
  # Trim to first two dash-separated words for compactness
  plan_short=$(echo "$session_slug" | cut -d'-' -f1-2)
  plan_part="  [plan:${plan_short}]"
fi

# Model: extract just haiku/sonnet/opus from display name
model_short=""
if [ -n "$model" ]; then
  model_lower=$(echo "$model" | tr '[:upper:]' '[:lower:]')
  if echo "$model_lower" | grep -q "haiku"; then
    model_short="  haiku"
  elif echo "$model_lower" | grep -q "opus"; then
    model_short="  opus"
  elif echo "$model_lower" | grep -q "sonnet"; then
    model_short="  sonnet"
  else
    # Fallback: use display name but strip version numbers
    model_clean=$(echo "$model" | sed 's/ [0-9][0-9.-]*$//')
    model_short="  $model_clean"
  fi
fi

# Billing mode: statsig cache is the ground truth for subscription type.
# ANTHROPIC_API_KEY presence is NOT a reliable indicator — users can have
# an API key set for other tools while running Claude Max via OAuth.
billing=""
statsig_file=$(ls "$HOME/.claude/statsig/statsig.cached.evaluations."* 2>/dev/null | head -1)
if [ -n "$statsig_file" ]; then
  sub_type=$(grep -ao '"subscriptionType":"[^"]*"' "$statsig_file" 2>/dev/null \
             | head -1 | sed 's/"subscriptionType":"//;s/"//')
  case "$sub_type" in
    max)  billing="  max" ;;
    pro)  billing="  pro" ;;
    free) billing="  free" ;;
    "")   : ;;
    *)    billing="  $sub_type" ;;
  esac
fi
# Fallback: only invoke claude auth status if statsig found no subscription
if [ -z "$billing" ] && [ -n "$ANTHROPIC_API_KEY" ]; then
  auth_method=$(claude auth status 2>/dev/null | jq -r '.authMethod // empty')
  if [ "$auth_method" = "claude.ai" ]; then
    billing="  max"
  else
    billing="  api"
  fi
fi

printf "%s%s%s%s%s%s%s" "$dir_name" "$git_branch" "$session_part" "$plan_part" "$ctx" "$model_short" "$billing"
