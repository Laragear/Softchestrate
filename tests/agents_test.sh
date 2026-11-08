#!/bin/sh
#
# Tests for install-agents.sh. Run from anywhere: sh tests/agents_test.sh
#
# The installer is copy-only: it never prompts, so there is no terminal
# machinery to fake here.

set -u

INSTALL=$(cd "$(dirname "$0")/.." && pwd)/install-agents.sh
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT

HOME=$ROOT/home
export HOME
mkdir -p "$HOME"

PASSED=0
FAILED=0
FAILURES=""

# ---- fixtures --------------------------------------------------------------

make_source() { # dir: a stable fixture tree, 3 shipped files
  mkdir -p "$1/agents/guides"
  echo "alpha v1" > "$1/agents/alpha.md"
  echo "beta v1" > "$1/agents/beta.md"
  echo "nested v1" > "$1/agents/guides/nested.md"
}

SHIPPED="agents/alpha.md agents/beta.md agents/guides/nested.md"

setup() { # fresh SRC and TARGET per case
  CASE=$(mktemp -d "$ROOT/case.XXXXXX")
  SRC=$CASE/src
  TARGET=$CASE/target/agents
  make_source "$SRC"
}

# run_install [args]: sets STATUS and OUT (stdout and stderr combined).
run_install() {
  STATUS=0
  (
    export ORCHESTRATE_HOME=$CASE/target ORCHESTRATE_SOURCE=$SRC
    sh "$INSTALL" "$@" > "$CASE/out" 2>&1
  ) || STATUS=$?
  OUT=$(cat "$CASE/out")
}

# ---- assertions (return 1 and print a reason on failure) --------------------

fail() { echo "    $*"; return 1; }

assert_status() { # expected
  [ "$STATUS" -eq "$1" ] || fail "exit status $STATUS, expected $1"
}

assert_file() { # path expected-content
  [ -f "$1" ] || { fail "missing file: $1"; return 1; }
  [ "$(cat "$1")" = "$2" ] || fail "$1 holds '$(cat "$1")', expected '$2'"
}

assert_absent() { # path
  [ ! -e "$1" ] || fail "should not exist: $1"
}

assert_contains() { # haystack needle
  case $1 in
    *"$2"*) return 0 ;;
  esac
  fail "missing text: $2"
}

assert_summary() { # installed updated unchanged
  assert_contains "$OUT" "Summary: $1 installed, $2 updated, $3 unchanged."
}

# ---- cases -----------------------------------------------------------------

test_fresh_install() {
  setup
  run_install
  assert_status 0 || return 1
  for f in $SHIPPED; do
    assert_file "$CASE/target/$f" "$(cat "$SRC/$f")" || return 1
  done
  assert_summary 3 0 0
}

test_rerun_unchanged() {
  setup
  run_install
  # Age a file and a reference to the same old time. A rewrite makes it newer.
  touch -t 200101010000 "$TARGET/alpha.md" "$CASE/ref"
  run_install
  assert_status 0 || return 1
  assert_summary 0 0 3 || return 1
  [ -z "$(find "$TARGET/alpha.md" -newer "$CASE/ref")" ] || fail "unchanged file was rewritten"
}

test_rerun_overwrites_edits() {
  setup
  run_install
  echo "my edit" > "$TARGET/alpha.md"
  run_install
  assert_status 0 || return 1
  assert_file "$TARGET/alpha.md" "alpha v1" || return 1
  assert_summary 0 1 2
}

test_untracked_file_is_kept() {
  setup
  run_install
  echo "mine" > "$TARGET/personal.md"
  run_install
  assert_status 0 || return 1
  assert_file "$TARGET/personal.md" "mine"
}

test_upstream_change_updates() {
  setup
  run_install
  echo "beta v2" > "$SRC/agents/beta.md"
  run_install
  assert_status 0 || return 1
  assert_file "$TARGET/beta.md" "beta v2" || return 1
  assert_summary 0 1 2
}

test_dry_run_writes_nothing() {
  setup
  run_install --dry-run
  assert_status 0 || return 1
  assert_absent "$CASE/target/agents" || return 1
  assert_contains "$OUT" "Dry run" || return 1
  assert_summary 3 0 0
}

test_dry_run_reports_update() {
  setup
  run_install
  echo "my edit" > "$TARGET/alpha.md"
  run_install --dry-run
  assert_status 0 || return 1
  assert_file "$TARGET/alpha.md" "my edit" || return 1
  assert_summary 0 1 2 || return 1
  assert_contains "$OUT" "updated    alpha.md"
}

test_source_without_agents() {
  setup
  rm -rf "$SRC/agents"
  run_install
  [ "$STATUS" -ne 0 ] || { fail "expected non-zero exit"; return 1; }
  assert_contains "$OUT" "no agents/ directory" || return 1
  assert_absent "$CASE/target"
}

test_help_and_unknown_option() {
  setup
  run_install --help
  assert_status 0 || return 1
  assert_contains "$OUT" "Usage: install-agents.sh" || return 1
  run_install --bogus
  [ "$STATUS" -ne 0 ] || { fail "unknown option should fail"; return 1; }
  assert_contains "$OUT" "install-agents.sh: unknown option: --bogus (try --help)"
}

test_download_path() {
  setup
  # A fixture tarball shaped like a GitHub archive: one top-level directory.
  mkdir -p "$CASE/tar/Orchestrate-v9"
  make_source "$CASE/tar/Orchestrate-v9"
  # COPYFILE_DISABLE stops macOS tar from adding ._ metadata files.
  COPYFILE_DISABLE=1 tar -czf "$CASE/fixture.tar.gz" -C "$CASE/tar" Orchestrate-v9
  # Fake curl: log the URL, copy the tarball to the -o target.
  mkdir "$CASE/bin"
  cat > "$CASE/bin/curl" <<FAKE
#!/bin/sh
while [ \$# -gt 0 ]; do
  case \$1 in -o) out=\$2; shift ;; *) url=\$1 ;; esac
  shift
done
echo "\$url" > "$CASE/url"
cp "$CASE/fixture.tar.gz" "\$out"
FAKE
  chmod +x "$CASE/bin/curl"
  STATUS=0
  (
    export PATH=$CASE/bin:$PATH ORCHESTRATE_HOME=$CASE/target ORCHESTRATE_REF=v9
    unset ORCHESTRATE_SOURCE
    sh "$INSTALL" > "$CASE/out" 2>&1
  ) || STATUS=$?
  OUT=$(cat "$CASE/out")
  assert_status 0 || return 1
  assert_contains "$(cat "$CASE/url" 2>/dev/null)" "/archive/v9.tar.gz" || return 1
  assert_file "$CASE/target/agents/alpha.md" "alpha v1" || return 1
  assert_summary 3 0 0
}

# ---- runner ----------------------------------------------------------------

run_case() { # function-name
  if "$1" > "$ROOT/case.log" 2>&1; then
    echo "ok - $1"
    PASSED=$((PASSED + 1))
  else
    echo "not ok - $1"
    sed 's/^/    /' "$ROOT/case.log"
    sed 's/^/    | /' "$CASE/out" 2>/dev/null
    FAILED=$((FAILED + 1))
  fi
}

for t in test_fresh_install test_rerun_unchanged test_rerun_overwrites_edits \
  test_untracked_file_is_kept test_upstream_change_updates \
  test_dry_run_writes_nothing test_dry_run_reports_update \
  test_source_without_agents test_help_and_unknown_option test_download_path; do
  run_case "$t"
done

echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
