#!/bin/bash
# sync-pull.sh — Pull project learnings back to central Smurf Village brain
# Usage: ./scripts/sync-pull.sh <target-project-path>
#        ./scripts/sync-pull.sh --all   (scans all known projects)

set -euo pipefail

SMURFS_DIR="$(cd "$(dirname "$0")/.." && pwd)"

pull_from_project() {
    local project_dir="$1"
    local learnings_file="$project_dir/.claude/project-learnings.md"

    if [ ! -f "$learnings_file" ]; then
        return 0
    fi

    # Check if there's unsynced content
    local has_content
    has_content=$(grep -cv '^#\|^$\|^---\|^<!--\|^Findings\|^This file\|^\[SYNCED\]' "$learnings_file" 2>/dev/null || echo "0")

    if [ "$has_content" -eq 0 ]; then
        return 0
    fi

    local project_name
    project_name=$(basename "$project_dir")
    echo "  Pulling learnings from: $project_name"

    # Extract unsynced entries (lines not marked as synced)
    local temp_file
    temp_file=$(mktemp)
    grep -v '^\[SYNCED\]' "$learnings_file" | grep -v '^#\|^---' | grep -v '^$\|^Findings\|^This file' > "$temp_file" 2>/dev/null || true

    if [ -s "$temp_file" ]; then
        # Append to central memory with project attribution
        echo "" >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
        echo "## From: $project_name ($(date -u '+%Y-%m-%d'))" >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
        cat "$temp_file" >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"

        # Mark entries as synced in the project file
        sed -i '' 's/^## \([0-9]\)/[SYNCED] ## \1/' "$learnings_file" 2>/dev/null || true

        echo "    -> Pulled and marked as synced"
    fi

    rm -f "$temp_file"
}

echo "=== Smurf Village Sync Pull ==="

# Initialize cross-project-learnings if it doesn't exist
if [ ! -f "$SMURFS_DIR/memory/patterns/cross-project-learnings.md" ]; then
    echo "# Cross-Project Learnings" > "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
    echo "" >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
    echo "Aggregated learnings from all projects, pulled via sync-pull." >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
    echo "" >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
    echo "---" >> "$SMURFS_DIR/memory/patterns/cross-project-learnings.md"
fi

if [ "${1:-}" = "--all" ]; then
    echo "Scanning all known project directories..."
    echo ""

    # Scan wesoco works
    for dir in ~/workspace/wesoco/works/*/; do
        [ -d "$dir" ] && pull_from_project "$dir"
    done

    # Scan other known projects
    for dir in ~/workspace/qoommerce/qoommerce-app ~/workspace/loodos/a101-mep-backend ~/workspace/wesoco/PostHive; do
        [ -d "$dir" ] && pull_from_project "$dir"
    done
else
    TARGET_DIR="${1:?Usage: $0 <target-project-path> or $0 --all}"
    TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
        echo "Error: Directory does not exist: $1"
        exit 1
    }
    pull_from_project "$TARGET_DIR"
fi

echo ""
echo "=== Sync Pull Complete ==="
