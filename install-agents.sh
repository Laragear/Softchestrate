#!/bin/sh
#
# Installs the Orchestrate subagent definitions in ~/.agents/agents.
#
#   curl -fsSL https://raw.githubusercontent.com/Laragear/Orchestrate/1.x/install-agents.sh | sh
#
# The skills are not handled here: install them with the skills.sh CLI instead,
# with `npx skills add Laragear/Orchestrate`.
#
# Copy-only: every run makes the installed files identical to the repository's
# agents/ directory. It installs new files, overwrites files that upstream
# changed, and leaves files that are already equal untouched. Anything else in
# the target directory is never touched. Run it with --dry-run to preview.
# Shipped paths must not contain spaces.

set -eu

REPO="Laragear/Orchestrate"
REF="${ORCHESTRATE_REF:-1.x}"
AGENTS_ROOT="${ORCHESTRATE_HOME:-$HOME/.agents}"
TARGET="$AGENTS_ROOT/agents"

DRY_RUN=0
N_INSTALLED=0
N_UPDATED=0
N_UNCHANGED=0

die() {
  printf 'install-agents.sh: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: install-agents.sh [--dry-run]

Installs the Orchestrate subagent definitions in ~/.agents/agents.
Every run makes the installed files identical to the repository's versions.

  --dry-run   report what would change and write nothing
  -h, --help  show this help

Environment:
  ORCHESTRATE_HOME    install root (default: ~/.agents)
  ORCHESTRATE_REF     branch, tag or commit to install (default: 1.x)
  ORCHESTRATE_SOURCE  install from this local checkout instead of downloading
EOF
}

while [ $# -gt 0 ]; do
  case $1 in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

command -v tar >/dev/null 2>&1 || die "tar is required"

fetch() { # url file
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$2" "$1"
  else
    die "curl or wget is required"
  fi
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [ -n "${ORCHESTRATE_SOURCE:-}" ]; then
  SRC=$ORCHESTRATE_SOURCE
  SOURCE_NAME="local checkout $SRC"
else
  SRC="$TMP/source"
  SOURCE_NAME="$REPO@$REF"
  echo "Downloading $SOURCE_NAME"
  fetch "https://github.com/$REPO/archive/$REF.tar.gz" "$TMP/archive.tar.gz" ||
    die "could not download https://github.com/$REPO/archive/$REF.tar.gz"
  mkdir "$SRC"
  tar -xzf "$TMP/archive.tar.gz" -C "$SRC" --strip-components=1
fi

if [ ! -d "$SRC/agents" ]; then
  die "$SOURCE_NAME has no agents/ directory"
fi

echo "Orchestrate agents from $SOURCE_NAME into $TARGET"
if [ "$DRY_RUN" -eq 1 ]; then
  echo "Dry run: nothing will be written."
fi

find "$SRC/agents" -type f > "$TMP/listing"
while IFS= read -r path; do
  rel=${path#"$SRC/agents/"}
  file="$TARGET/$rel"
  if [ -f "$file" ] && cmp -s "$path" "$file"; then
    N_UNCHANGED=$((N_UNCHANGED + 1))
    continue
  fi
  if [ -f "$file" ]; then
    label=updated
    N_UPDATED=$((N_UPDATED + 1))
  else
    label=installed
    N_INSTALLED=$((N_INSTALLED + 1))
  fi
  if [ "$DRY_RUN" -eq 0 ]; then
    mkdir -p "$(dirname "$file")"
    cp -p "$path" "$file"
  fi
  printf '  %-10s %s\n' "$label" "$rel"
done < "$TMP/listing"

echo
echo "Summary: $N_INSTALLED installed, $N_UPDATED updated, $N_UNCHANGED unchanged."
if [ "$DRY_RUN" -eq 0 ] && [ $((N_INSTALLED + N_UPDATED)) -gt 0 ]; then
  echo "The skills install with: npx skills add $REPO"
  echo "Next: adapt the files in $TARGET to your harness (see Adapting to your harness in the README)."
fi
