#!/bin/sh
#
# Tests the skills.sh install path: that the skills CLI discovers every skill
# in this repository, that every definition follows the frontmatter rules of
# AGENTS.md, and that a real install copies every skill.
#
# Needs npx (Node.js 22.20 or later) and network access: the CLI itself is
# downloaded on each run. Run from anywhere: sh tests/skills_test.sh

set -u

REPO=$(cd "$(dirname "$0")/.." && pwd)
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT

PASSED=0
FAILED=0

if ! command -v npx >/dev/null 2>&1; then
  echo "skills_test.sh: npx is required (Node.js 22.20 or later)" >&2
  exit 1
fi

N_SKILLS=$(find "$REPO/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

# run_skills [args...]: runs the CLI against this repository, sets STATUS and OUT.
run_skills() {
  STATUS=0
  npx -y skills add "$REPO" "$@" > "$ROOT/out" 2>&1 || STATUS=$?
  OUT=$(cat "$ROOT/out")
}

# ---- frontmatter ------------------------------------------------------------

# awk program: prints "KEY\t<key>\t<value>" for every top-level frontmatter
# key, or "ERR\t<why>" and a failed exit status when the block is malformed.
FMKEYS='
NR == 1 {
  if ($0 != "---") { print "ERR\tfirst line is not ---"; bad = 1; exit }
  infm = 1; next
}
infm && $0 == "---" { closed = 1; exit }
infm && /^[A-Za-z][A-Za-z-]*:/ {
  c = index($0, ":")
  key = substr($0, 1, c - 1)
  val = substr($0, c + 1)
  sub(/^[ \t]+/, "", val)
  if (key in seen) { print "ERR\tduplicate key " key; bad = 1; exit }
  seen[key] = 1
  print "KEY\t" key "\t" val
}
END {
  if (bad) exit 1
  if (!closed) { print "ERR\tfrontmatter never closes"; exit 1 }
}'

ALLOWED=" allowed-tools compatibility complexity description license metadata name "

check_definition() { # file expected-name
  f=$1; expected=$2
  [ -f "$f" ] || { fail "missing definition: $f"; return 1; }
  fm="$ROOT/fm.txt"
  awk "$FMKEYS" "$f" > "$fm" || { fail "$f: $(grep '^ERR' "$fm" | cut -f2)"; return 1; }

  for k in $(cut -f2 "$fm" | sort -u); do
    case $ALLOWED in
      *" $k "*) ;;
      *) fail "$f: unexpected frontmatter key: $k"; return 1 ;;
    esac
  done

  fm_value() { # key
    awk -F'\t' -v k="$1" '$2 == k { print $3; exit }' "$fm"
  }

  strip_quotes() { # value: drop one pair of surrounding double quotes
    v=$1
    case $v in
      '"'*'"') v=${v#\"}; v=${v%\"} ;;
    esac
    printf '%s' "$v"
  }

  name=$(strip_quotes "$(fm_value name)")
  [ "$name" = "$expected" ] || { fail "$f: name is '$name', expected '$expected'"; return 1; }

  desc=$(strip_quotes "$(fm_value description)")
  [ -n "$desc" ] || { fail "$f: no description"; return 1; }
  [ "${#desc}" -le 1024 ] || { fail "$f: description is ${#desc} chars, the Agent Skills spec allows 1024"; return 1; }

  if [ "${f##*/}" = SKILL.md ]; then
    grep -q '^metadata:' "$f" &&
      { fail "$f: skills must not carry a metadata block"; return 1; }
  else
    grep -Eq '^complexity: "(mundane|routine|interpreting|judgment|critical)"$' "$f" ||
      { fail "$f: complexity must be one of mundane, routine, interpreting, judgment, critical"; return 1; }
  fi

  dir=$(dirname "$f")
  for p in $(grep -oE '(references|scripts)/[A-Za-z0-9._/-]+' "$f" | sort -u); do
    [ -f "$dir/$p" ] || { fail "$f: mentions $p, which does not exist"; return 1; }
  done
}

# ---- assertions (return 1 and print a reason on failure) --------------------

fail() { echo "    $*"; return 1; }

assert_contains() { # haystack needle
  case $1 in
    *"$2"*) return 0 ;;
  esac
  fail "missing text: $2"
}

# ---- cases -----------------------------------------------------------------

test_frontmatter_is_valid() {
  rc=0
  for f in "$REPO"/agents/*.md; do
    check_definition "$f" "$(basename "$f" .md)" || rc=1
  done
  for d in "$REPO"/skills/*/; do
    check_definition "$d/SKILL.md" "$(basename "$d")" || rc=1
  done
  return $rc
}

test_list_discovers_all_skills() {
  run_skills --list
  [ "$STATUS" -eq 0 ] || { fail "exit status $STATUS, expected 0"; return 1; }
  assert_contains "$OUT" "Found $N_SKILLS skills" || return 1
  for d in "$REPO"/skills/*/; do
    assert_contains "$OUT" "$(basename "$d")" || return 1
  done
}

test_install_copies_all_skills() {
  CASE=$(mktemp -d "$ROOT/case.XXXXXX")
  STATUS=0
  (
    cd "$CASE" &&
      npx -y skills add "$REPO" --skill '*' -a universal -y --copy > "$CASE/out" 2>&1
  ) || STATUS=$?
  OUT=$(cat "$CASE/out")
  [ "$STATUS" -eq 0 ] || { fail "exit status $STATUS, expected 0"; return 1; }
  [ "$(find "$CASE/.agents/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -eq "$N_SKILLS" ] ||
    { fail "installed skill count does not match $N_SKILLS"; return 1; }
  for d in "$REPO"/skills/*/; do
    name=$(basename "$d")
    cmp -s "$d/SKILL.md" "$CASE/.agents/skills/$name/SKILL.md" ||
      fail "installed $name/SKILL.md differs from the repository"
  done
}

# ---- runner ----------------------------------------------------------------

run_case() { # function-name
  if "$1" > "$ROOT/case.log" 2>&1; then
    echo "ok - $1"
    PASSED=$((PASSED + 1))
  else
    echo "not ok - $1"
    sed 's/^/    /' "$ROOT/case.log"
    sed 's/^/    | /' "$ROOT/out" 2>/dev/null
    FAILED=$((FAILED + 1))
  fi
}

for t in test_frontmatter_is_valid test_list_discovers_all_skills \
  test_install_copies_all_skills; do
  run_case "$t"
done

echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
