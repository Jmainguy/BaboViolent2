#!/usr/bin/env bash
# Automated smoke test: local BaboMasterServer + BaboViolentDedicated (LaunchScript/FFA.cfg) with 127.0.0.1 bv2.db.
# Exits 0 if the dedicated stays connected to the master (no immediate "client ID ... disconnected").
#
# Requires: built BaboMasterServer and BaboViolentDedicated, sqlite3, fuser or ss, timeout.
# Optional client: set TEST_CLIENT=1 and have xvfb-run + BaboViolent (heavy; skipped by default).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${BUILD:-$ROOT/build}"
MASTER_BIN="$BUILD/BaboMasterServer"
DED_BIN="$BUILD/BaboViolentDedicated"
TMP="${TMPDIR:-/tmp}/bv2-stack-test-$$"

need() { command -v "$1" >/dev/null 2>&1 || { echo "need $1" >&2; exit 1; }; }
need sqlite3
need timeout
[[ -x "$MASTER_BIN" ]] || { echo "build BaboMasterServer first: $MASTER_BIN" >&2; exit 1; }
[[ -x "$DED_BIN" ]] || { echo "build BaboViolentDedicated first: $DED_BIN" >&2; exit 1; }

free_tcp() {
	local p="${1:-10207}"
	if command -v fuser >/dev/null 2>&1; then
		fuser -k "${p}/tcp" 2>/dev/null || true
	else
		for pid in $(ss -ltnp "sport = :$p" 2>/dev/null | sed -n 's/.*pid=\([0-9]*\).*/\1/p' | sort -u); do
			[[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
		done
	fi
	sleep 0.2
}

cleanup() {
	free_tcp 10207
	rm -rf "$TMP"
}
trap cleanup EXIT INT TERM

cleanup
mkdir -p "$TMP"
cp -a "$MASTER_BIN" "$TMP/m"
cp -a "$ROOT/Content/master.db" "$ROOT/Content/web.db" "$TMP/"

cd "$TMP"
stdbuf -oL -eL ./m >master.stdout 2>master.stderr &
MPID=$!
cd "$ROOT"

for _ in $(seq 1 80); do
	ss -ltn "sport = :10207" 2>/dev/null | grep -q 10207 && break
	sleep 0.05
done
sleep 0.35

MASTER_HOST=127.0.0.1 CONTENT_DIR="$ROOT/Content" bash "$ROOT/scripts/write-bv2-db.sh"

# Run dedicated from Content/ (bv2.db, maps, LaunchScript paths).
set +e
(cd "$ROOT/Content" && timeout 25 "$DED_BIN" FFA >"$TMP/ded.stdout" 2>"$TMP/ded.stderr")
DED_RC=$?
set -e

sleep 0.4
kill "$MPID" 2>/dev/null || true
	wait "$MPID" 2>/dev/null || true

FAIL=0
if grep -qi "stream rejected\|potential hacking" "$TMP/master.stdout" "$TMP/master.stderr" 2>/dev/null; then
	echo "FAIL: master logged hacking / bad stream" >&2
	FAIL=1
fi
if grep -qE 'errno = 101|connect\(\) failed' "$TMP/ded.stderr" "$TMP/ded.stdout" 2>/dev/null; then
	echo "FAIL: dedicated could not reach master (errno 101 / connect)" >&2
	FAIL=1
fi
if ! grep -q "Update from player .* OK" "$TMP/master.stdout" 2>/dev/null; then
	echo "FAIL: dedicated never registered (no 'Update from player … OK' in master log)" >&2
	FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
	echo "--- master.stdout (tail) ---"
	tail -20 "$TMP/master.stdout" 2>/dev/null || true
	echo "--- ded.stderr (grep) ---"
	grep -nE 'master|connect|errno|Error|hack' "$TMP/ded.stderr" 2>/dev/null || true
	exit 1
fi

echo "OK: stack test passed (master + dedicated, no immediate disconnect / errno 101)."
exit 0
