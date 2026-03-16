#!/usr/bin/env bash
# Claude Code status line - compact single-line format for narrow terminals
# Receives JSON via stdin

input=$(cat)

# Single jq parse for all fields (@sh quotes values for safe eval with spaces)
eval "$(echo "$input" | jq -r '
  "cwd=" + (.workspace.current_dir // .cwd // "" | @sh),
  "model=" + (.model.display_name // "" | @sh),
  "used=" + ((.context_window.used_percentage // "" | tostring) | @sh),
  "session_id=" + (.session_id // "" | @sh),
  "transcript_path=" + (.transcript_path // "" | @sh)
')"

# Show only the directory name (basename), not the full path
if [ -n "$cwd" ]; then
  dir_name=$(basename "$cwd")
else
  dir_name="~"
fi

# Git branch + dirty indicator
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_branch="  $branch"
    # Append * if working tree has staged or unstaged changes
    if ! git -C "$cwd" diff --quiet 2>/dev/null || ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
      git_branch="${git_branch}*"
    fi
  fi
fi

# Context usage - always show; escalate format at thresholds
ctx=""
if [ -n "$used" ] && [ "$used" != "null" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 90 ] 2>/dev/null; then
    ctx="  [${used_int}%!]"
  else
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
    model_clean=$(echo "$model" | sed 's/ [0-9][0-9.-]*$//')
    model_short="  $model_clean"
  fi
fi

# Billing mode: claude auth status JSON.
# authMethod "claude.ai" = OAuth subscription (Max/Pro/Enterprise).
# orgName and orgId reflect email domain, not plan type -- not usable for tier detection.
billing=""
auth_json=$(claude auth status 2>/dev/null)
if [ -n "$auth_json" ]; then
  auth_method=$(echo "$auth_json" | jq -r '.authMethod // empty')
  if [ "$auth_method" = "claude.ai" ]; then
    billing="  max"
  fi
fi
# Fallback if auth status unavailable or returned unknown auth method
if [ -z "$billing" ]; then
  if [ -z "$ANTHROPIC_API_KEY" ]; then billing="  max"
  else billing="  api"; fi
fi

printf "%s%s%s%s%s%s%s" "$dir_name" "$git_branch" "$session_part" "$plan_part" "$ctx" "$model_short" "$billing"
