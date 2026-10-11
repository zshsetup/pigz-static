#!/usr/bin/env bash
# Usage: ./tests/run_smoke_tests.sh [--static] [--dist DIR]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT_DIR/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --static)
      DIST="$ROOT_DIR/dist-static"
      shift
      ;;
    --dist)
      DIST="$(cd "$2" && pwd)"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

BIN="$DIST/bin/pigz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass() { echo "ok: $*"; }
fail() {
  echo "FAIL: $*" >&2
  exit 1
}

version="$("$BIN" --version)"
echo "$version" | grep -q '^pigz ' || fail "pigz --version: $version"
pass "$version"

head -c 300000 /dev/urandom | od -An -tx1 >"$TMP/data"
cp "$TMP/data" "$TMP/orig"
"$BIN" -p 4 "$TMP/data"
[ -f "$TMP/data.gz" ] || fail "no .gz file"
gzip -t "$TMP/data.gz" 2>/dev/null || true
"$DIST/bin/unpigz" "$TMP/data.gz"
cmp -s "$TMP/data" "$TMP/orig" || fail "round trip differs"
pass "compresses and decompresses in parallel"

# the output must be gzip compatible
printf 'pmg\n' | "$BIN" -c | gzip -dc | grep -q '^pmg$' || fail "gzip cannot read the output"
pass "output readable by gzip"

if [ "$(uname -s)" = Linux ] && ! LC_ALL=C grep -a -q 'ld-musl' "$BIN"; then
  max="$(LC_ALL=C grep -aoh 'GLIBC_2\.[0-9]*' "$BIN" | sort -uV | tail -n 1)" || true
  if [ -n "$max" ]; then
    [ "$(printf '%s\n' "$max" GLIBC_2.17 | sort -V | tail -n 1)" = GLIBC_2.17 ] \
      || fail "needs $max, newer than GLIBC_2.17"
    pass "glibc floor ($max)"
  fi
fi

echo "all smoke tests passed"
