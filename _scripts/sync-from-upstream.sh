#!/usr/bin/env bash
# =============================================================================
# Cowork Starter Kit — Sync From Upstream
# =============================================================================
# Pulls the latest cowork-app-starter content from the public GitHub mirror
# (github.com/ibrahim-hz/cowork-starter-kit) and applies template-only files
# to THIS kit folder, preserving per-app customizations.
#
# Designed to run from inside Cowork's sandbox in any downstream project that
# has the kit installed. Read-only: never pushes anywhere, never modifies
# anything outside this kit folder.
#
# Usage:
#   ./sync-from-upstream.sh           # interactive: dry-run, then prompt to apply
#   ./sync-from-upstream.sh --apply   # non-interactive: apply immediately
#   ./sync-from-upstream.sh --dry-run # show what would change, then exit
#
# Exit codes:
#   0 = success or dry-run completed
#   1 = preflight failure (wrong folder, network failure, etc.)
#   2 = sync aborted by user at the confirmation prompt
# =============================================================================

set -euo pipefail
set +x

# ---------- Hardcoded targets (NEVER change without explicit review) ---------
readonly UPSTREAM_REPO="https://github.com/ibrahim-hz/cowork-starter-kit.git"
readonly SENTINEL_FILES=("README.md" "STARTER-PROJECT-PLANNING.md" "STARTER-KIT-BUILD-PLAN.md")

# ---------- Args -------------------------------------------------------------
MODE="interactive"
if [ $# -gt 0 ]; then
  case "$1" in
    --apply)   MODE="apply" ;;
    --dry-run) MODE="dry-run" ;;
    *)
      echo "ERROR: Unknown arg '$1'. Use --apply or --dry-run, or no args for interactive." >&2
      exit 1
      ;;
  esac
fi

# ---------- Self-locate ------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
KIT_FOLDER="$(dirname "$SCRIPT_DIR")"

# ---------- Sentinel check: is KIT_FOLDER actually the kit? ------------------
for sentinel in "${SENTINEL_FILES[@]}"; do
  if [ ! -f "$KIT_FOLDER/$sentinel" ]; then
    echo "ABORT: '$KIT_FOLDER' doesn't look like a kit folder (missing $sentinel)." >&2
    echo "       This script must live in <kit-folder>/_scripts/ and the kit folder must contain README.md + STARTER-PROJECT-PLANNING.md + STARTER-KIT-BUILD-PLAN.md." >&2
    exit 1
  fi
done

echo "Kit folder: $KIT_FOLDER"
echo "Upstream:   $UPSTREAM_REPO"
echo ""

# ---------- Clone upstream into sandbox /tmp/ --------------------------------
WORK_DIR="/tmp/kit-sync-$$"
cleanup() {
  local code=$?
  if [ -n "${WORK_DIR:-}" ] && [ -d "$WORK_DIR" ]; then
    rm -rf "$WORK_DIR" 2>/dev/null || true
  fi
  exit $code
}
trap cleanup EXIT INT TERM

mkdir -p "$WORK_DIR"
echo "Cloning upstream into sandbox..."
if ! git clone "$UPSTREAM_REPO" "$WORK_DIR/upstream" >/dev/null 2>&1; then
  echo "ABORT: git clone failed. Verify github.com is reachable and the repo exists." >&2
  exit 1
fi

# ---------- Exclude list — per-app files that must NOT be overwritten -------
# These belong to the consuming app, not to upstream. The sync NEVER touches them.
RSYNC_EXCLUDES=(
  # Git internals
  --exclude='.git/'
  # The sync script itself (don't replace mid-run; future syncs handle it)
  --exclude='_scripts/'

  # Per-app renames of kit standards docs
  # (the user is encouraged to rename STARTER-*.md → *.md when adapting the kit;
  #  the renamed versions are app-owned and never overwritten by sync)
  --exclude='PROJECT-VISION.md'
  --exclude='PROJECT-PLANNING.md'
  --exclude='QA-STANDARDS.md'
  --exclude='QUICK-FIXES.md'
  --exclude='CLAUDE-CODE-RUNBOOK.md'
  --exclude='BEFORE-LAUNCH-CHECKLIST.md'
  --exclude='SUB-AGENT-METHODOLOGY.md'
  --exclude='DEPLOYMENT-WORKFLOW.md'

  # Per-app tracker working copy (the hosted Pages tracker is the canonical UI;
  # but if the user maintains a local copy for offline use, don't overwrite it)
  --exclude='PLANNING-TRACKER.html'

  # Per-app sprint folders (any number-prefixed folder is the user's actual sprints)
  --exclude='[0-9] - */'
  --exclude='[0-9][0-9] - */'

  # Per-app bug history
  --exclude='C - Bugs/open/'
  --exclude='C - Bugs/fixed/'
  --exclude='C - Bugs/wont-fix/'
  --exclude='C - Bugs/BACKLOG.md'

  # Per-app ADRs (numbered files belong to the user; the _template.md + README.md ship from upstream)
  --exclude='D - Decisions/[0-9]*.md'
  --exclude='D - Decisions/INDEX.md'

  # Per-app mockups
  --exclude='mockups/'

  # Secrets & gitignored content (defense-in-depth — these shouldn't exist in the kit anyway)
  --exclude='CREDENTIALS.md'
  --exclude='.env'
  --exclude='.env.*'
  --exclude='secrets/'
  --exclude='STARTER-KIT-SYNC-LOG.md'
)

# ---------- Always run dry-run first ----------------------------------------
echo ""
echo "=========================================================="
echo "DRY RUN — what the sync would change:"
echo "=========================================================="
DRY_OUTPUT=$(rsync -ai --dry-run "${RSYNC_EXCLUDES[@]}" "$WORK_DIR/upstream/" "$KIT_FOLDER/")
if [ -z "$DRY_OUTPUT" ]; then
  echo "(no changes — kit folder is already at upstream's state)"
  echo ""
  echo "SUCCESS: Already up to date."
  exit 0
fi
echo "$DRY_OUTPUT"
echo "=========================================================="

# ---------- Stop here if --dry-run mode ----------
if [ "$MODE" = "dry-run" ]; then
  echo ""
  echo "Dry run only. No changes applied. Re-run with --apply (or no args) to apply."
  exit 0
fi

# ---------- Interactive confirmation ----------
if [ "$MODE" = "interactive" ]; then
  echo ""
  echo -n "Apply these changes? [y/N]: "
  read -r CONFIRM
  case "$CONFIRM" in
    y|Y|yes|Yes|YES) ;;
    *)
      echo "Sync cancelled. No changes applied."
      exit 2
      ;;
  esac
fi

# ---------- Apply the sync ----------
echo ""
echo "Applying sync..."
rsync -a "${RSYNC_EXCLUDES[@]}" "$WORK_DIR/upstream/" "$KIT_FOLDER/"

echo ""
echo "SUCCESS: Synced from $UPSTREAM_REPO"
echo "         Kit folder updated: $KIT_FOLDER"
echo ""
echo "Notes:"
echo "  - The sync script itself (_scripts/) is excluded from sync; if upstream"
echo "    ships a new version of this script, the next sync after a manual copy"
echo "    will pick it up. Or you can re-copy the kit folder fully."
echo "  - Your per-app files (PROJECT-VISION, PROJECT-PLANNING, sprint folders,"
echo "    bugs, ADRs, mockups, secrets) were NOT touched."
echo "  - Review the changed files and commit them to your app's repo as a"
echo "    normal commit (this script does not commit anything itself)."

exit 0
