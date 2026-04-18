#!/usr/bin/env bash
#
# bootstrap.sh — install the eng-team template into a target project.
#
# Usage:
#   /path/to/eng-team/scripts/bootstrap.sh <target-dir> [--force]
#
# What it does:
#   1. Reads .eng-team.manifest for the list of managed paths.
#   2. Copies each managed path from this repo into <target-dir>.
#   3. Seeds .claude/memory/ with README + local .gitignore (one-time only).
#   4. Writes .eng-team.lock with the upstream commit SHA so future syncs
#      can detect drift.
#
# Refuses to run if <target-dir>/.eng-team.lock already exists, unless
# --force is passed. For existing projects, use scripts/sync-eng-team.sh
# instead.

set -euo pipefail

# Paths relative to source repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$SOURCE_ROOT/.eng-team.manifest"

# Files that are copied ONCE during bootstrap (never synced afterwards)
SEED_PATHS=(
  ".claude/memory/README.md"
  ".claude/memory/.gitignore"
)

usage() {
  cat <<EOF
Usage: $0 <target-dir> [--force]

  <target-dir>   Directory to bootstrap into (must exist).
  --force        Overwrite even if <target-dir>/.eng-team.lock exists.

Example:
  gh repo clone ckansiz/eng-team /tmp/eng-team-src
  /tmp/eng-team-src/scripts/bootstrap.sh ~/workspace/my-new-project
EOF
}

log() { printf '  %s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }

# --- arg parse --------------------------------------------------------------

TARGET=""
FORCE=0
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --force)   FORCE=1 ;;
    -*)        err "unknown flag: $arg"; usage; exit 2 ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$arg"
      else
        err "unexpected argument: $arg"; exit 2
      fi
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  err "target directory required"
  usage
  exit 2
fi

# --- validate ---------------------------------------------------------------

if [[ ! -d "$TARGET" ]]; then
  err "target directory does not exist: $TARGET"
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

if [[ ! -f "$MANIFEST" ]]; then
  err "manifest not found at $MANIFEST"
  err "is $SOURCE_ROOT actually an eng-team checkout?"
  exit 1
fi

if [[ -f "$TARGET/.eng-team.lock" && "$FORCE" -ne 1 ]]; then
  err "target already has .eng-team.lock — use scripts/sync-eng-team.sh instead"
  err "(pass --force to re-bootstrap anyway)"
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  err "rsync not found — install it first (macOS: preinstalled; debian: apt install rsync)"
  exit 1
fi

# --- read manifest ----------------------------------------------------------

PATHS=()
while IFS= read -r raw; do
  line="${raw%%#*}"                                    # strip inline comments
  line="$(printf '%s' "$line" | sed 's/[[:space:]]*$//;s/^[[:space:]]*//')"
  [[ -z "$line" ]] && continue
  PATHS+=("$line")
done < "$MANIFEST"

if [[ ${#PATHS[@]} -eq 0 ]]; then
  err "manifest is empty"
  exit 1
fi

# --- bootstrap --------------------------------------------------------------

printf 'Bootstrapping eng-team template\n'
printf '  source : %s\n' "$SOURCE_ROOT"
printf '  target : %s\n' "$TARGET"
printf '\n'

copy_path() {
  local rel="$1"
  local src="$SOURCE_ROOT/$rel"
  local dst="$TARGET/$rel"

  if [[ ! -e "$src" ]]; then
    log "skip  $rel  (not present in source)"
    return
  fi

  mkdir -p "$(dirname "$dst")"
  if [[ -d "$src" ]]; then
    # Directory: recursive copy. No --delete during bootstrap (we don't know
    # what's already in target; sync is the place to clean up stale files).
    rsync -a "$src/" "$dst/"
    log "dir   $rel"
  else
    cp "$src" "$dst"
    log "file  $rel"
  fi
}

# Managed paths first
printf 'Managed paths:\n'
for p in "${PATHS[@]}"; do
  copy_path "$p"
done

# Seed paths (one-time)
printf '\nSeed paths (project-local, never synced):\n'
for p in "${SEED_PATHS[@]}"; do
  if [[ -e "$TARGET/$p" && "$FORCE" -ne 1 ]]; then
    log "keep  $p  (already exists in target)"
    continue
  fi
  copy_path "$p"
done

# Ensure memory/ dir exists even if seed files were absent
mkdir -p "$TARGET/.claude/memory"

# --- write lock file --------------------------------------------------------

UPSTREAM_URL="$(cd "$SOURCE_ROOT" && git config --get remote.origin.url 2>/dev/null || true)"
UPSTREAM_SHA="$(cd "$SOURCE_ROOT" && git rev-parse HEAD 2>/dev/null || true)"
UPSTREAM_BRANCH="$(cd "$SOURCE_ROOT" && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

cat > "$TARGET/.eng-team.lock" <<EOF
# eng-team template lock file — managed by scripts/sync-eng-team.sh. Do not edit.
upstream_url=${UPSTREAM_URL:-unknown}
upstream_branch=${UPSTREAM_BRANCH:-unknown}
upstream_sha=${UPSTREAM_SHA:-unknown}
bootstrapped_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
synced_at=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

printf '\n'
log "lock  .eng-team.lock  (upstream ${UPSTREAM_SHA:0:10})"

# --- ensure sync script is executable ---------------------------------------

if [[ -f "$TARGET/scripts/sync-eng-team.sh" ]]; then
  chmod +x "$TARGET/scripts/sync-eng-team.sh"
fi

# --- append .eng-team.lock to target .gitignore if needed -------------------

TARGET_GITIGNORE="$TARGET/.gitignore"
if [[ -f "$TARGET_GITIGNORE" ]]; then
  if ! grep -qE '^\.eng-team\.lock$' "$TARGET_GITIGNORE"; then
    {
      printf '\n# eng-team template sync lock (tracks upstream SHA)\n'
      printf '.eng-team.lock\n'
    } >> "$TARGET_GITIGNORE"
    log "edit  .gitignore  (appended .eng-team.lock)"
  fi
fi

# --- next steps --------------------------------------------------------------

cat <<EOF

Bootstrap complete.

Next steps:
  1. Populate .claude/memory/ with project context:
       - profile.md    (identity, preferences)
       - workspace.md  (paths, keywords, stacks)
       - clients/      (one file per client, if applicable)
  2. Customize root CLAUDE.md if the project needs deviations from defaults
     (or rely on memory/profile.md to override).
  3. Stage + commit the bootstrapped files in the target project.
  4. When the template updates upstream, run:
       ./scripts/sync-eng-team.sh --check
EOF
