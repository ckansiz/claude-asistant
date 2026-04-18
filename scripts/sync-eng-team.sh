#!/usr/bin/env bash
#
# sync-eng-team.sh — update managed paths from the upstream eng-team template.
#
# Reads .eng-team.lock for the upstream URL + branch + last-synced SHA, clones
# the upstream to a temp dir, and rsyncs each path listed in the upstream
# .eng-team.manifest into the current project. Anything not in the manifest
# is left alone.
#
# Modes:
#   default       show diff, confirm, apply, update lock
#   --dry-run     show diff, apply nothing
#   --check       print local vs remote SHA; exit 0 if in sync, 1 if behind
#   -y / --yes    skip the confirmation prompt
#
# Exits non-zero on error or when --check finds drift.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCK="$PROJECT_ROOT/.eng-team.lock"

log() { printf '  %s\n' "$*"; }
info() { printf '%s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }

usage() {
  cat <<EOF
Usage: $0 [--dry-run | --check] [-y|--yes]

  (no flag)     Sync managed paths from upstream template (with confirmation).
  --dry-run     Show what would change; do not modify anything.
  --check       Compare local lock SHA to upstream HEAD; exit 0 (synced) or 1 (behind).
  -y, --yes     Skip the confirmation prompt.
  -h, --help    This help text.

Reads upstream info from .eng-team.lock (written by bootstrap.sh).
EOF
}

# --- args -------------------------------------------------------------------

DRY_RUN=0
CHECK_ONLY=0
YES=0
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN=1 ;;
    --check)   CHECK_ONLY=1 ;;
    -y|--yes)  YES=1 ;;
    -*)        err "unknown flag: $arg"; usage; exit 2 ;;
    *)         err "unexpected argument: $arg"; usage; exit 2 ;;
  esac
done

if [[ $DRY_RUN -eq 1 && $CHECK_ONLY -eq 1 ]]; then
  err "--dry-run and --check are mutually exclusive"
  exit 2
fi

# --- read lock --------------------------------------------------------------

if [[ ! -f "$LOCK" ]]; then
  err "no .eng-team.lock at $LOCK"
  err "this project has not been bootstrapped. Run scripts/bootstrap.sh from the template first."
  exit 1
fi

read_lock_field() {
  local key="$1"
  grep -E "^${key}=" "$LOCK" | head -n1 | cut -d= -f2-
}

UPSTREAM_URL="$(read_lock_field upstream_url)"
UPSTREAM_BRANCH="$(read_lock_field upstream_branch)"
LOCAL_SHA="$(read_lock_field upstream_sha)"

if [[ -z "$UPSTREAM_URL" || "$UPSTREAM_URL" == "unknown" ]]; then
  err "lock file is missing a valid upstream_url"
  exit 1
fi
if [[ -z "$UPSTREAM_BRANCH" || "$UPSTREAM_BRANCH" == "unknown" ]]; then
  UPSTREAM_BRANCH="main"
fi

# --- tooling check ----------------------------------------------------------

for tool in git rsync; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    err "$tool not found in PATH"
    exit 1
  fi
done

# --- --check: cheap remote-only comparison ----------------------------------

if [[ $CHECK_ONLY -eq 1 ]]; then
  REMOTE_SHA="$(git ls-remote "$UPSTREAM_URL" "$UPSTREAM_BRANCH" 2>/dev/null | awk '{print $1}' | head -n1)"
  if [[ -z "$REMOTE_SHA" ]]; then
    err "could not read upstream (tried $UPSTREAM_URL $UPSTREAM_BRANCH)"
    exit 1
  fi
  if [[ "$REMOTE_SHA" == "$LOCAL_SHA" ]]; then
    info "up to date (${LOCAL_SHA:0:10})"
    exit 0
  fi
  info "behind: local=${LOCAL_SHA:0:10}  remote=${REMOTE_SHA:0:10}"
  info "run \`$0 --dry-run\` to preview changes, then \`$0\` to apply"
  exit 1
fi

# --- full sync: clone upstream to tmp ---------------------------------------

TMP="$(mktemp -d -t eng-team-sync.XXXXXX)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

UPSTREAM="$TMP/upstream"

info "Cloning upstream"
info "  url    : $UPSTREAM_URL"
info "  branch : $UPSTREAM_BRANCH"
info ""
git clone --depth 1 --branch "$UPSTREAM_BRANCH" --single-branch "$UPSTREAM_URL" "$UPSTREAM" 2>&1 | sed 's/^/  /'
REMOTE_SHA="$(cd "$UPSTREAM" && git rev-parse HEAD)"

info ""
info "Syncing eng-team template"
info "  local  : ${LOCAL_SHA:0:10}"
info "  remote : ${REMOTE_SHA:0:10}"
info ""
# Always scan even when SHAs match — the user may have modified a managed
# file locally, and sync's job is to revert it to upstream content.

# --- read upstream manifest (source of truth for what to sync) --------------

UPSTREAM_MANIFEST="$UPSTREAM/.eng-team.manifest"
if [[ ! -f "$UPSTREAM_MANIFEST" ]]; then
  err "upstream has no .eng-team.manifest at $UPSTREAM_BRANCH"
  exit 1
fi

PATHS=()
while IFS= read -r raw; do
  line="${raw%%#*}"
  line="$(printf '%s' "$line" | sed 's/[[:space:]]*$//;s/^[[:space:]]*//')"
  [[ -z "$line" ]] && continue
  PATHS+=("$line")
done < "$UPSTREAM_MANIFEST"

if [[ ${#PATHS[@]} -eq 0 ]]; then
  err "upstream manifest is empty"
  exit 1
fi

# --- rsync helpers ----------------------------------------------------------

# preview_changes <src> <dst>
#   Print a human-readable diff of what would change. Empty output = no changes.
#
# For directories: rsync -ani --checksum, filtered to drop mtime-only rows
# (lines starting with '.'). Lines starting with '>', '<', 'c', or '*' (e.g.
# '*deleting') indicate real transfers and are kept.
#
# For single files: rsync's itemize output on a single file is unreliable
# (it always prints '>f....... name' regardless of whether the file differs),
# so fall back to cmp -s and print our own one-liner.
preview_changes() {
  local src="$1"
  local dst="$2"

  if [[ -d "$src" ]]; then
    rsync -ani --checksum --delete "$src/" "$dst/" 2>/dev/null \
      | grep -vE '^\.' \
      || true
  else
    local name
    name="$(basename "$src")"
    if [[ ! -f "$dst" ]]; then
      printf '>f+++++++++ %s\n' "$name"
    elif ! cmp -s "$src" "$dst"; then
      printf '>f.cst..... %s\n' "$name"
    fi
  fi
}

# apply_changes <src> <dst>
#   Actually copy the changes. Used only after the user approves.
apply_changes() {
  local src="$1"
  local dst="$2"

  if [[ -d "$src" ]]; then
    rsync -a --checksum --delete "$src/" "$dst/"
  else
    cp "$src" "$dst"
  fi
}

# --- Phase A: diff pass -----------------------------------------------------

info "Changes pending:"
info ""

ANY_CHANGES=0
for p in "${PATHS[@]}"; do
  src="$UPSTREAM/$p"
  dst="$PROJECT_ROOT/$p"

  if [[ ! -e "$src" ]]; then
    log "skip  $p  (not in upstream)"
    continue
  fi

  mkdir -p "$(dirname "$dst")"
  output="$(preview_changes "$src" "$dst")"
  output="$(printf '%s\n' "$output" | sed '/^$/d')"

  if [[ -n "$output" ]]; then
    info "→ $p"
    printf '%s\n' "$output" | sed 's/^/    /'
    ANY_CHANGES=1
  fi
done

if [[ $ANY_CHANGES -eq 0 ]]; then
  info "  (managed paths already match upstream content)"
fi

# --- Phase B: apply or stop ------------------------------------------------

info ""

if [[ $DRY_RUN -eq 1 ]]; then
  info "Dry run — nothing applied."
  exit 0
fi

if [[ $ANY_CHANGES -eq 0 ]]; then
  info "Nothing to apply. Updating lock to ${REMOTE_SHA:0:10}."
else
  if [[ $YES -ne 1 ]]; then
    printf 'Apply changes? [y/N] '
    read -r ans || ans=""
    if [[ ! "$ans" =~ ^[Yy] ]]; then
      info "Aborted. No changes applied."
      exit 0
    fi
  fi

  info "Applying changes..."
  for p in "${PATHS[@]}"; do
    src="$UPSTREAM/$p"
    dst="$PROJECT_ROOT/$p"
    [[ -e "$src" ]] || continue
    mkdir -p "$(dirname "$dst")"
    apply_changes "$src" "$dst" >/dev/null
    log "sync  $p"
  done

  # Make sure the sync script itself stays executable after being overwritten.
  if [[ -f "$PROJECT_ROOT/scripts/sync-eng-team.sh" ]]; then
    chmod +x "$PROJECT_ROOT/scripts/sync-eng-team.sh"
  fi
fi

# --- update lock ------------------------------------------------------------

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
BOOTSTRAPPED_AT="$(read_lock_field bootstrapped_at)"
[[ -z "$BOOTSTRAPPED_AT" ]] && BOOTSTRAPPED_AT="$NOW"

cat > "$LOCK" <<EOF
# eng-team template lock file — managed by scripts/sync-eng-team.sh. Do not edit.
upstream_url=$UPSTREAM_URL
upstream_branch=$UPSTREAM_BRANCH
upstream_sha=$REMOTE_SHA
bootstrapped_at=$BOOTSTRAPPED_AT
synced_at=$NOW
EOF

info ""
info "Sync complete. Now at ${REMOTE_SHA:0:10}."
