#!/usr/bin/env bash
# Create Content/master.db and Content/web.db when missing or zero-byte.
# BaboMasterServer reads Settings from master.db; an empty file causes UB
# when a game server registers (BV2_ROW) and the client can hang on "Connecting".

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTENT="$ROOT/Content"
command -v sqlite3 >/dev/null || { echo "install sqlite3 (sqlite-tools)" >&2; exit 1; }

bootstrap() {
	local db="$1"
	local sql="$2"
	if [[ ! -s "$db" ]]; then
		rm -f "$db"
		sqlite3 "$db" <"$sql"
		echo "initialized $(basename "$db") from $(basename "$sql")"
	fi
}

mkdir -p "$CONTENT"
bootstrap "$CONTENT/master.db" "$ROOT/packaging/master-bootstrap.sql"
bootstrap "$CONTENT/web.db" "$ROOT/packaging/web-bootstrap.sql"
