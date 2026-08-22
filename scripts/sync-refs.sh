#!/usr/bin/env bash
# sync-refs.sh — Pull all reference repos and generate a change report
#
# Usage:
#   ./scripts/sync-refs.sh              # pull + diff + report
#   ./scripts/sync-refs.sh --report-only  # just regenerate report from last state
#   ./scripts/sync-refs.sh --pull-only    # just pull all refs, no report
#
# Output:
#   docs/sync-reports/YYYY-MM-DD.md     # structured change report
#   .aiassist/global/sync-refs-state.json  # persisted last-check timestamps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"
STATE_FILE="$WORKSPACE/.aiassist/global/sync-refs-state.json"
REPORT_DIR="$WORKSPACE/docs/sync-reports"
SKILLS_DIR="$WORKSPACE/skills"
REF_DIR="$WORKSPACE/reference"

# --- helpers ---

now_iso() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
today() { date +"%Y-%m-%d"; }

# --- pull all reference repos ---

do_pull() {
  echo "## Pulling reference repos..."
  for d in "$REF_DIR"/*/; do
    name=$(basename "$d")
    if [ -d "$d/.git" ]; then
      echo "  [$name] fetching..."
      (cd "$d" && git fetch origin 2>&1 | sed 's/^/    /') || echo "    WARN: fetch failed for $name"
      echo "  [$name] merging..."
      (cd "$d" && git merge --ff-only origin/main 2>&1 | sed 's/^/    /' || git merge --ff-only origin/master 2>&1 | sed 's/^/    /' || echo "    WARN: fast-forward failed for $name")
    else
      echo "  [$name] SKIP: not a git repo"
    fi
  done
  echo ""
}

# --- read last-check timestamps ---

read_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  else
    echo '{"repos":{},"last_sync":null}'
  fi
}

write_state() {
  mkdir -p "$(dirname "$STATE_FILE")"
  echo "$1" > "$STATE_FILE"
}

# --- extract reference paths that a skill depends on ---

extract_refs_for_skill() {
  local sources_file="$1"
  local skill_name="$2"
  grep -o 'reference/[a-z-]\+/[^ )`]\+' "$sources_file" 2>/dev/null | sed 's/`$//' | sort -u || true
}

# --- map a reference path to its repo name ---

ref_path_to_repo() {
  local path="$1"
  # path format: reference/<repo>/<rest>
  echo "$path" | sed 's|reference/||' | cut -d/ -f1
}

# --- map a reference path to file path inside the repo ---

ref_path_to_file() {
  local path="$1"
  # path format: reference/<repo>/<rest> → remove reference/<repo>/
  local repo=$(echo "$path" | sed 's|reference/||' | cut -d/ -f1)
  echo "$path" | sed "s|reference/$repo/||"
}

# --- generate report ---

generate_report() {
  local state
  state=$(read_state)

  local report_file="$REPORT_DIR/$(today).md"
  mkdir -p "$REPORT_DIR"

  {
    echo "# Sync Report — $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo "## Reference repo status"
    echo ""

    # Status per repo
    for d in "$REF_DIR"/*/; do
      name=$(basename "$d")
      if [ -d "$d/.git" ]; then
        last_commit=$(cd "$d" && git log -1 --format='%ci %s' 2>/dev/null || echo "unknown")
        branch=$(cd "$d" && git branch --show-current 2>/dev/null || echo "detached")
        echo "- **$name** ($branch): $last_commit"
      else
        echo "- **$name**: not a git repo"
      fi
    done

    echo ""
    echo "## Changes by skill"
    echo ""

    local prev_sync=$(echo "$state" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('last_sync','never'))" 2>/dev/null || echo "never")

    # For each skill, check its reference dependencies
    for skill_dir in "$SKILLS_DIR"/productivity/*/ "$SKILLS_DIR"/engineering/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_name=$(basename "$skill_dir")
      local sources_file="$skill_dir/SOURCES.md"

      if [ ! -f "$sources_file" ]; then
        continue
      fi

      local refs
      refs=$(extract_refs_for_skill "$sources_file" "$skill_name")

      if [ -z "$refs" ]; then
        continue
      fi

      echo "### \`$skill_name\`"
      echo ""

      local has_changes=false

      while IFS= read -r ref_path; do
        [ -z "$ref_path" ] && continue

        local repo=$(ref_path_to_repo "$ref_path")
        local file=$(ref_path_to_file "$ref_path")
        local full_path="$REF_DIR/$repo/$file"

        if [ ! -f "$full_path" ]; then
          echo "- ⚠️  \`$ref_path\` — **FILE MISSING** (moved or deleted upstream)"
          has_changes=true
          continue
        fi

        local log
        if [ "$prev_sync" = "never" ]; then
          log=$(cd "$REF_DIR/$repo" && git log -1 --format='%ci %s' -- "$file" 2>/dev/null || echo "unknown")
          echo "- 🆕 \`$ref_path\` — first check, latest: $log"
          has_changes=true
        else
          # Get commits since last sync for this file
          local since="${prev_sync}"
          log=$(cd "$REF_DIR/$repo" && git log --since="$since" --format='%h %ci %s' -- "$file" 2>/dev/null || true)
          if [ -n "$log" ]; then
            echo "- 🔄 \`$ref_path\` — changed:"
            echo "$log" | sed 's/^/    /'
            has_changes=true
          else
            echo "- ✅ \`$ref_path\` — no changes"
          fi
        fi
        echo ""
      done <<< "$refs"

      if [ "$has_changes" = false ]; then
        echo "_No changes in any reference dependency._"
        echo ""
      fi
    done

    echo "## Actions needed"
    echo ""
    echo "For each 🔄 or 🆕 item above:"
    echo "1. Read the updated reference file"
    echo "2. Decide: absorb / skip / later"
    echo "3. If absorbing, update the skill's SKILL.md and SOURCES.md"
    echo "4. See docs/sync-refs.md for the absorb / skip / later decision flow"
    echo ""
    echo "---"
    echo "Report generated at $(now_iso)"

  } > "$report_file"

  # Update state with new timestamp
  local new_state
  new_state=$(echo "$state" | python3 -c "
import sys, json
d = json.load(sys.stdin)
d['last_sync'] = '$(now_iso)'
print(json.dumps(d, indent=2))
" 2>/dev/null)
  write_state "$new_state"

  echo "Report written: $report_file"
  echo "State updated: last_sync=$(now_iso)"
}

# --- main ---

case "${1:-}" in
  --pull-only)
    do_pull
    ;;
  --report-only)
    generate_report
    ;;
  *)
    do_pull
    generate_report
    ;;
esac
