#!/usr/bin/env bash
# Write Content/bv2.db so client/dedicated use your master (not the public default).
#
# MasterServers.Port in the DB must be TCP_listen + 1000 (e.g. 11207 for 10207).
#
# Usage (from repo root):
#   ./scripts/write-bv2-db.sh
#   ./scripts/write-bv2-db.sh 192.168.86.40
#   ./scripts/write-bv2-db.sh 127.0.0.1 10207
#
# Packaged tree (run.sh cwd is Content/; db lives next to main/):
#   CONTENT_DIR="$HOME/bv2-ded/Content" ./scripts/write-bv2-db.sh 192.168.86.40
#
# Env overrides: MASTER_HOST, MASTER_TCP, CONTENT_DIR, ACCOUNT_URL

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MASTER_HOST="${1:-${MASTER_HOST:-127.0.0.1}}"
MASTER_TCP="${2:-${MASTER_TCP:-10207}}"
CONTENT_DIR="${CONTENT_DIR:-$ROOT/Content}"
ACCOUNT_URL="${ACCOUNT_URL:-http://127.0.0.1/}"
MASTER_DB_PORT=$((MASTER_TCP + 1000))

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need sqlite3

mkdir -p "$CONTENT_DIR"
db="$CONTENT_DIR/bv2.db"
rm -f "$db"
sqlite3 "$db" <<SQL
CREATE TABLE MasterServers (
  Score INTEGER,
  Id INTEGER,
  IP TEXT,
  Location TEXT,
  Port INTEGER
);
INSERT INTO MasterServers VALUES (0, 1, '${MASTER_HOST}', 'custom', ${MASTER_DB_PORT});

CREATE TABLE LauncherSettings (
  Name TEXT,
  Value TEXT
);
INSERT INTO LauncherSettings VALUES ('Version', '4.0');
INSERT INTO LauncherSettings VALUES ('DBVersion', '0');
INSERT INTO LauncherSettings VALUES ('AccountURL', '${ACCOUNT_URL}');
INSERT INTO LauncherSettings VALUES ('DidSurvey', '0');
SQL
echo "Wrote $db (master ${MASTER_HOST}:${MASTER_TCP}, DB Port column ${MASTER_DB_PORT})"
