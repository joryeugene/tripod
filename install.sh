#!/usr/bin/env bash
# tripod installer
# Usage: curl -fsSL https://raw.githubusercontent.com/joryeugene/tripod/main/install.sh | bash
set -euo pipefail

REPO="joryeugene/tripod"
CLAUDEMD_URL="https://raw.githubusercontent.com/joryeugene/tripod/main/CLAUDE.md"
MARKETPLACE_FILE="$HOME/.claude/plugins/known_marketplaces.json"
INSTALLED_FILE="$HOME/.claude/plugins/installed_plugins.json"
PLUGIN_KEY="tripod@tripod"
EXPECTED_HOOKS=6
EXPECTED_SKILLS=21

log() { printf '[tripod] %s\n' "$*"; }
die() { printf '[tripod] ERROR: %s\n' "$*" >&2; exit 1; }

# ── Prerequisites ──────────────────────────────────────────────────────────────

log "Checking prerequisites..."

if ! command -v claude >/dev/null 2>&1; then
  die "claude CLI required. Install: https://claude.ai/download"
fi

HAS_PYTHON=false
if command -v python3 >/dev/null 2>&1; then
  HAS_PYTHON=true
fi

log "Prerequisites ok."

# ── Marketplace ────────────────────────────────────────────────────────────────

already_in_marketplace() {
  "$HAS_PYTHON" && [ -f "$MARKETPLACE_FILE" ] && \
    python3 -c "
import json, sys
data = json.load(open('$MARKETPLACE_FILE'))
sys.exit(0 if 'tripod' in data else 1)
" 2>/dev/null
}

if already_in_marketplace; then
  log "Marketplace: already registered."
else
  log "Registering marketplace..."
  claude plugin marketplace add "$REPO"
fi

# ── Plugin install / update ────────────────────────────────────────────────────

log "Installing plugin (this may take a moment)..."
claude plugin install tripod

# ── CLAUDE.md ─────────────────────────────────────────────────────────────────

mkdir -p "$HOME/.claude"

install_claudemd() {
  local src
  # prefer local copy if script is run from the repo
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
  if [ -f "$script_dir/CLAUDE.md" ]; then
    src="$script_dir/CLAUDE.md"
    cp "$src" "$HOME/.claude/CLAUDE.md"
  else
    curl -fsSL "$CLAUDEMD_URL" -o "$HOME/.claude/CLAUDE.md"
  fi
  log "CLAUDE.md installed -> $HOME/.claude/CLAUDE.md"
}

if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  if [ -t 0 ]; then
    # Interactive: ask
    printf '[tripod] ~/.claude/CLAUDE.md already exists. Replace it? [y/N] '
    read -r answer </dev/tty
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      ts="$(date '+%Y%m%d-%H%M%S')"
      cp "$HOME/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md.bak.$ts"
      log "Backed up -> ~/.claude/CLAUDE.md.bak.$ts"
      install_claudemd
    else
      log "Skipping CLAUDE.md (kept existing)."
    fi
  else
    # curl pipe: no TTY, auto-skip
    log "No TTY detected. Skipping CLAUDE.md. Run 'bash install.sh' directly to choose."
  fi
else
  install_claudemd
fi

# ── Verify ─────────────────────────────────────────────────────────────────────

log "Verifying installation..."

if ! "$HAS_PYTHON"; then
  log "python3 not found -- skipping JSON verification. Run ./verify manually."
else
  if [ ! -f "$INSTALLED_FILE" ]; then
    die "Plugin install file not found at $INSTALLED_FILE. Something went wrong."
  fi

  plugin_found=$(python3 -c "
import json, sys
data = json.load(open('$INSTALLED_FILE'))
sys.exit(0 if '$PLUGIN_KEY' in data.get('plugins', {}) else 1)
" 2>/dev/null && echo true || echo false)

  if [ "$plugin_found" != "true" ]; then
    die "Plugin not found in $INSTALLED_FILE after install. Try: claude plugin install tripod"
  fi

  install_path=$(python3 -c "
import json
data = json.load(open('$INSTALLED_FILE'))
entries = data['plugins']['$PLUGIN_KEY']
print(entries[0]['installPath'])
" 2>/dev/null)

  skill_count=$(ls "$install_path/skills/" 2>/dev/null | wc -l | tr -d ' ')
  hook_count=$(ls "$install_path/hooks/"*.py 2>/dev/null | wc -l | tr -d ' ')

  if [ "$skill_count" -lt "$EXPECTED_SKILLS" ] || [ "$hook_count" -lt "$EXPECTED_HOOKS" ]; then
    log "WARNING: expected ${EXPECTED_SKILLS} skills and ${EXPECTED_HOOKS} hooks,"
    log "         found ${skill_count} skills and ${hook_count} hooks."
    log "         Try: claude plugin install tripod"
  else
    log "Verified: ${skill_count} skills, ${hook_count} hooks."
  fi
fi

# ── Done ───────────────────────────────────────────────────────────────────────

printf '\n'
log "Done. Start a new Claude Code session to activate."
printf '\n'
printf 'Core principles (full version in CLAUDE.md):\n'
printf '  Verification    "should work" is banned. Run it, show the output.\n'
printf '  Schema first    80%% of bugs are field name mismatches. Check data before theorizing.\n'
printf '  Error recovery  Stop. Do not defend. Get actual data.\n'
printf '\n'
printf 'To add the full philosophy layer:\n'
printf '  curl -fsSL %s >> ~/.claude/CLAUDE.md\n' "$CLAUDEMD_URL"
printf '\n'
