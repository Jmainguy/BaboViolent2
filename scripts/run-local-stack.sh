#!/usr/bin/env bash
# Run BaboMasterServer + BaboViolentDedicated against a local master.
#
# With no bv2.db (or an empty file), the game uses the built-in default master
# (babo.soh.re:10207). If that host is unreachable from your network, connect()
# fails with errno 101 (ENETUNREACH). This script writes a minimal Content/bv2.db
# pointing MasterServers at 127.0.0.1 with port column 11207 (TCP listen 10207 + 1000).
#
# Usage:
#   ./scripts/run-local-stack.sh              # start master, then dedicated FFA (LaunchScript/FFA.cfg)
#   ./scripts/run-local-stack.sh CTF          # use LaunchScript/CTF.cfg instead
#   MASTER_HOST=192.168.1.5 ./scripts/run-local-stack.sh CTF

set -euo pipefail

# Join / TCP [net] logs on the dedicated console (overrides c_netlog after bv2.cfg load).
export BV2_NETLOG="${BV2_NETLOG:-1}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTENT="$ROOT/Content"
BUILD="${BUILD:-$ROOT/build}"
MASTER_BIN="$BUILD/BaboMasterServer"
DED_BIN="$BUILD/BaboViolentDedicated"
MASTER_TCP="${MASTER_TCP:-10207}"
MASTER_HOST="${MASTER_HOST:-127.0.0.1}"
MODE="${1:-FFA}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }

need sqlite3
bash "$ROOT/scripts/ensure-master-databases.sh"
[[ -x "$MASTER_BIN" ]] || { echo "Build BaboMasterServer first: $MASTER_BIN" >&2; exit 1; }
[[ -x "$DED_BIN" ]] || { echo "Build BaboViolentDedicated first: $DED_BIN" >&2; exit 1; }

write_client_bv2_db() {
	MASTER_HOST="$MASTER_HOST" MASTER_TCP="$MASTER_TCP" CONTENT_DIR="$CONTENT" \
		bash "$ROOT/scripts/write-bv2-db.sh"
}

cleanup() {
	if [[ -n "${MASTER_PID:-}" ]] && kill -0 "$MASTER_PID" 2>/dev/null; then
		echo "Stopping master (pid $MASTER_PID)..."
		kill "$MASTER_PID" 2>/dev/null || true
		wait "$MASTER_PID" 2>/dev/null || true
	fi
}
trap cleanup EXIT INT TERM

write_client_bv2_db

echo "Net diagnostics: BV2_NETLOG=${BV2_NETLOG} (dedicated shows [net] lines). Client: open console (~) or ensure main/bv2.cfg has c_netlog true."

cd "$CONTENT"
echo "Starting BaboMasterServer..."
"$MASTER_BIN" &
MASTER_PID=$!

# Wait until something is listening on MASTER_TCP (best-effort)
port_listening() {
	if command -v ss >/dev/null 2>&1; then
		ss -ltn "sport = :$MASTER_TCP" 2>/dev/null | grep -q ":$MASTER_TCP"
		return $?
	fi
	# Fallback: bash TCP probe
	(echo >/dev/tcp/127.0.0.1/"$MASTER_TCP") >/dev/null 2>&1
}
for _ in $(seq 1 50); do
	if port_listening; then
		break
	fi
	if ! kill -0 "$MASTER_PID" 2>/dev/null; then
		echo "Master exited early; check Content/master.db / web.db" >&2
		exit 1
	fi
	sleep 0.1
done

echo "Starting BaboViolentDedicated $MODE (Ctrl+C exits and stops master)..."
"$DED_BIN" "$MODE"
