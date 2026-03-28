#!/bin/bash
# sync-push.sh — Push master smurf agents and shared patterns to a project
# Usage: ./scripts/sync-push.sh <target-project-path>
# Example: ./scripts/sync-push.sh ~/workspace/wesoco/works/oltan

set -euo pipefail

SMURFS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="${1:?Usage: $0 <target-project-path>}"

# Resolve target path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo "Error: Target directory does not exist: $1"
    exit 1
}

echo "=== Sirin Koyu Sync Push ==="
echo "Source: $SMURFS_DIR"
echo "Target: $TARGET_DIR"
echo ""

# 1. Create .claude/agents/ in target if it doesn't exist
mkdir -p "$TARGET_DIR/.claude/agents"

# 2. Copy master agent definitions
echo "Deploying smurf agents..."
cp "$SMURFS_DIR/.claude/agents/"*.md "$TARGET_DIR/.claude/agents/"
echo "  -> Copied $(ls "$SMURFS_DIR/.claude/agents/"*.md | wc -l | tr -d ' ') agent files"

# 3. Merge shared patterns into project rules (without overwriting existing rules)
mkdir -p "$TARGET_DIR/.claude/rules"

# Create/update shared-patterns.md (this file is managed by sync, safe to overwrite)
echo "Merging shared patterns..."
SHARED_PATTERNS="$TARGET_DIR/.claude/rules/shared-patterns.md"
echo "# Shared Patterns (auto-synced from Sirin Koyu)" > "$SHARED_PATTERNS"
echo "# Last sync: $(date -u '+%Y-%m-%d %H:%M UTC')" >> "$SHARED_PATTERNS"
echo "" >> "$SHARED_PATTERNS"

for pattern_file in "$SMURFS_DIR/memory/patterns/"*.md; do
    if [ -f "$pattern_file" ]; then
        filename=$(basename "$pattern_file")
        # Only include if file has actual content (not just template)
        content_lines=$(grep -cv '^#\|^$\|^---\|^<!--' "$pattern_file" 2>/dev/null || echo "0")
        if [ "$content_lines" -gt 0 ]; then
            echo "## From $filename" >> "$SHARED_PATTERNS"
            echo "" >> "$SHARED_PATTERNS"
            cat "$pattern_file" >> "$SHARED_PATTERNS"
            echo "" >> "$SHARED_PATTERNS"
        fi
    fi
done
echo "  -> Updated shared-patterns.md"

# 4. Create project-learnings.md if it doesn't exist
if [ ! -f "$TARGET_DIR/.claude/project-learnings.md" ]; then
    echo "# Project Learnings" > "$TARGET_DIR/.claude/project-learnings.md"
    echo "" >> "$TARGET_DIR/.claude/project-learnings.md"
    echo "Findings from smurf agents working in this project." >> "$TARGET_DIR/.claude/project-learnings.md"
    echo "This file is periodically synced back to the central Sirin Koyu brain." >> "$TARGET_DIR/.claude/project-learnings.md"
    echo "" >> "$TARGET_DIR/.claude/project-learnings.md"
    echo "---" >> "$TARGET_DIR/.claude/project-learnings.md"
    echo "" >> "$TARGET_DIR/.claude/project-learnings.md"
    echo "  -> Created project-learnings.md"
fi

# 5. Summary
echo ""
echo "=== Sync Push Complete ==="
echo "Agents deployed. Project-specific files (rules/, CLAUDE.md) were NOT modified."
echo ""
echo "Files in $TARGET_DIR/.claude/agents/:"
ls "$TARGET_DIR/.claude/agents/"*.md 2>/dev/null | while read f; do echo "  - $(basename "$f")"; done
