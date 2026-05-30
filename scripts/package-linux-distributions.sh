#!/usr/bin/env bash
# Build three self-contained zip trees for Linux x86_64:
#   dist/BaboMasterServer-linux.zip
#   dist/BaboViolentDedicated-linux.zip
#   dist/BaboViolent-linux.zip
#
# Each unpacks to its own directory; run ./run.sh from that directory.
# Shared libraries (except glibc core) are copied into lib/ and LD_LIBRARY_PATH is set.
#
# Usage (from repo root):
#   ./scripts/package-linux-distributions.sh
#   BUILD=/path/to/build ./scripts/package-linux-distributions.sh
#
# Requires: zip, cp, ldd, awk, cmake (optional: builds Release if binaries missing)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="${BUILD:-$ROOT/build}"
DIST="$ROOT/dist"
STAGE="$DIST/.staging-$$"

MASTER_BIN="$BUILD/BaboMasterServer"
DED_BIN="$BUILD/BaboViolentDedicated"
CLI_BIN="$BUILD/BaboViolent"

die() { echo "error: $*" >&2; exit 1; }

command -v zip >/dev/null || die "install zip (e.g. dnf install zip)"
command -v sqlite3 >/dev/null || die "install sqlite3 (needed to bootstrap master.db / web.db)"

bash "$ROOT/scripts/ensure-master-databases.sh"

mkdir -p "$DIST"

if [[ ! -x "$MASTER_BIN" || ! -x "$DED_BIN" || ! -x "$CLI_BIN" ]]; then
	echo "Binaries missing; running cmake --build (Release)..."
	cmake -S "$ROOT" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release >/dev/null
	cmake --build "$BUILD" --target BaboMasterServer BaboViolentDedicated BaboViolent -j"$(nproc)"
fi
[[ -x "$MASTER_BIN" ]] || die "no executable: $MASTER_BIN"
[[ -x "$DED_BIN" ]] || die "no executable: $DED_BIN"
[[ -x "$CLI_BIN" ]] || die "no executable: $CLI_BIN"

# Copy ldd closure into dest/lib (skip glibc + dynamic linker).
collect_libs() {
	local dest_libdir="$1"
	shift
	mkdir -p "$dest_libdir"
	declare -A scanned
	declare -A copied_realpath
	local -a stack=("$@")
	local f libpath bn realp

	is_skipped() {
		case "$1" in
			*/libc.so.6|*/libm.so.6|*/libpthread.so.0|*/libdl.so.2|*/librt.so.1|*/ld-linux-x86-64.so.2|*/ld-linux.so.2) return 0 ;;
		esac
		return 1
	}

	while ((${#stack[@]})); do
		f="${stack[0]}"
		stack=("${stack[@]:1}")
		[[ -f "$f" ]] || continue
		realp=$(readlink -f "$f" 2>/dev/null || echo "$f")
		[[ ${scanned[$realp]+x} ]] && continue
		scanned[$realp]=1

		while IFS= read -r libpath; do
			[[ -f "$libpath" ]] || continue
			is_skipped "$libpath" && continue
			realp=$(readlink -f "$libpath" 2>/dev/null || echo "$libpath")
			[[ ${copied_realpath[$realp]+x} ]] && continue
			bn=$(basename "$libpath")
			cp -L "$libpath" "$dest_libdir/$bn"
			chmod a+r "$dest_libdir/$bn"
			copied_realpath[$realp]=1
			stack+=("$dest_libdir/$bn")
		done < <(ldd "$f" 2>/dev/null | awk '$3 ~ /^\// {print $3}')
	done
}

write_readme_master() {
	local d="$1"
	cat >"$d/README.txt" <<'EOF'
BaboMasterServer (Linux x86_64)
--------------------------------
Unpack anywhere. From this directory run:

  ./run.sh

Uses master.db and web.db in this directory. If they are empty/corrupt, run:
  ./bootstrap-databases.sh
(SQL sources are included next to it.) TCP listen port is 10207
(source: src/MasterListingServer/cNetManager.cpp).

Game servers / clients elsewhere should point bv2.db MasterServers at this host
with Port = listen_tcp + 1000 (e.g. 11207 for 10207).

Bundled lib/ is used via LD_LIBRARY_PATH so this tree can sit on a machine without
matching dev packages. You still need a normal glibc-based x86_64 system.
EOF
}

write_readme_game() {
	local name="$1"
	local d="$2"
	cat >"$d/README.txt" <<EOF
$name (Linux x86_64)
-------------------
Unpack anywhere. From this directory run:

  ./run.sh [args...]

Examples:
  ./run.sh FFA              # dedicated: run launch script FFA.cfg (FFA, port 3334 in repo script)
  ./run.sh CTF              # dedicated: run launch script CTF.cfg
  ./run.sh                  # client: no args

The working directory for the game is ./Content (maps, cfg, sounds, etc.).

Bundled lib/ covers non-glibc dependencies (SDL, OpenGL, OpenSSL, curl, etc.).

This zip omits bv2.db so the client uses the built-in default master (see
CMaster::GetMasterInfos). To use a local master, add Content/bv2.db with
MasterServers pointing at your host; Port column = TCP listen + 1000 (11207 for 10207).
EOF
}

write_run_master() {
	local d="$1"
	cat >"$d/run.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
export LD_LIBRARY_PATH="$DIR/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$DIR/bin/BaboMasterServer" "$@"
EOF
	chmod +x "$d/run.sh"
}

write_run_game() {
	local exe="$1"
	local d="$2"
	cat >"$d/run.sh" <<EOF
#!/usr/bin/env bash
set -euo pipefail
DIR="\$(cd "\$(dirname "\$0")" && pwd)"
export LD_LIBRARY_PATH="\$DIR/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
cd "\$DIR/Content" || { echo "missing Content/ next to run.sh" >&2; exit 1; }
exec "\$DIR/bin/$exe" "\$@"
EOF
	chmod +x "$d/run.sh"
}

cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

rm -f "$DIST"/BaboMasterServer-linux.zip "$DIST"/BaboViolentDedicated-linux.zip "$DIST"/BaboViolent-linux.zip

# --- Master ---
M="$STAGE/master"
mkdir -p "$M/bin" "$M/lib"
cp -a "$MASTER_BIN" "$M/bin/BaboMasterServer"
chmod +x "$M/bin/BaboMasterServer"
collect_libs "$M/lib" "$M/bin/BaboMasterServer"
[[ -s "$ROOT/Content/master.db" ]] || die "master.db missing or empty after ensure-master-databases.sh"
[[ -s "$ROOT/Content/web.db" ]] || die "web.db missing or empty after ensure-master-databases.sh"
cp -a "$ROOT/Content/master.db" "$M/"
cp -a "$ROOT/Content/web.db" "$M/"
cp -a "$ROOT/packaging/master-bootstrap.sql" "$M/"
cp -a "$ROOT/packaging/web-bootstrap.sql" "$M/"
cat >"$M/bootstrap-databases.sh" <<'BOOT'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
command -v sqlite3 >/dev/null || { echo "install sqlite3" >&2; exit 1; }
sqlite3 master.db <master-bootstrap.sql
sqlite3 web.db <web-bootstrap.sql
echo "OK: rewrote master.db and web.db in $(pwd)"
BOOT
chmod +x "$M/bootstrap-databases.sh"
write_readme_master "$M"
write_run_master "$M"
(
	cd "$M" && zip -qr "$DIST/BaboMasterServer-linux.zip" .
)
echo "Wrote $DIST/BaboMasterServer-linux.zip ($(du -h "$DIST/BaboMasterServer-linux.zip" | cut -f1))"

# --- Dedicated ---
D="$STAGE/dedicated"
mkdir -p "$D/bin" "$D/lib"
cp -a "$DED_BIN" "$D/bin/BaboViolentDedicated"
chmod +x "$D/bin/BaboViolentDedicated"
collect_libs "$D/lib" "$D/bin/BaboViolentDedicated"
cp -a "$ROOT/Content" "$D/Content"
# Never ship a dev-only bv2.db (e.g. 127.0.0.1 from run-local-stack); missing file → CMaster defaults.
rm -f "$D/Content/bv2.db"
write_readme_game "BaboViolentDedicated" "$D"
write_run_game "BaboViolentDedicated" "$D"
(
	cd "$D" && zip -qr "$DIST/BaboViolentDedicated-linux.zip" .
)
echo "Wrote $DIST/BaboViolentDedicated-linux.zip ($(du -h "$DIST/BaboViolentDedicated-linux.zip" | cut -f1))"

# --- Client ---
C="$STAGE/client"
mkdir -p "$C/bin" "$C/lib"
cp -a "$CLI_BIN" "$C/bin/BaboViolent"
chmod +x "$C/bin/BaboViolent"
collect_libs "$C/lib" "$C/bin/BaboViolent"
cp -a "$ROOT/Content" "$C/Content"
rm -f "$C/Content/bv2.db"
write_readme_game "BaboViolent (client)" "$C"
write_run_game "BaboViolent" "$C"
(
	cd "$C" && zip -qr "$DIST/BaboViolent-linux.zip" .
)
echo "Wrote $DIST/BaboViolent-linux.zip ($(du -h "$DIST/BaboViolent-linux.zip" | cut -f1))"

echo "Done. Unzip each into its own empty directory and run ./run.sh"
