#!/usr/bin/env bash
# Configure and build all three BV2 targets for CI / release packaging.
#
# Usage:
#   BV2_PLATFORM=linux|windows|macos ./scripts/ci-build.sh
#
# Optional:
#   BUILD=/path/to/build-dir   (default: build-<platform> under repo root)
#   OSXCROSS_SDK_VERSION=12.3  (macOS cross; must match setup-osxcross osx-version)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BV2_PLATFORM="${BV2_PLATFORM:?set BV2_PLATFORM=linux|windows|macos}"
BUILD="${BUILD:-$ROOT/build-${BV2_PLATFORM}}"

# Always configure in a clean build directory. This avoids CMake cache
# source-path mismatches when build artifacts were created on another machine.
rm -rf "$BUILD"
mkdir -p "$BUILD"

TOOLCHAIN=""
CMAKE_EXTRA=()

case "$BV2_PLATFORM" in
	linux)
		;;
	windows)
		TOOLCHAIN="$ROOT/cmake/toolchains/mingw-w64.cmake"
		CMAKE_EXTRA+=(-DDIRECTX=OFF)
		command -v x86_64-w64-mingw32-g++ >/dev/null || {
			echo "error: install g++-mingw-w64-x86-64" >&2
			exit 1
		}
		;;
	macos)
		TOOLCHAIN="$ROOT/cmake/toolchains/osxcross-x86_64.cmake"
		SDK_VER="${OSXCROSS_SDK_VERSION:-12.3}"
		CMAKE_EXTRA+=("-DOSXCross_SDK_VERSION=${SDK_VER}")
		# SDL enables -Werror=declaration-after-statement when supported; this
		# breaks Objective-C sources under osxcross clang. Keep macOS CI permissive.
		CMAKE_EXTRA+=(-DHAVE_GCC_WERROR_DECLARATION_AFTER_STATEMENT=FALSE)
		CMAKE_EXTRA+=(-DHAVE_GCC_WDECLARATION_AFTER_STATEMENT=FALSE)
		[[ -n "${OSXCROSS_TARGET:-}" ]] || {
			echo "error: OSXCROSS_TARGET not set (run setup-osxcross in CI first)" >&2
			exit 1
		}
		;;
	*)
		echo "error: unknown BV2_PLATFORM=$BV2_PLATFORM" >&2
		exit 1
		;;
esac

CMAKE_ARGS=(
	-S "$ROOT"
	-B "$BUILD"
	-DCMAKE_BUILD_TYPE=Release
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5
)

if [[ -n "$TOOLCHAIN" ]]; then
	CMAKE_ARGS+=(-DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN")
fi
CMAKE_ARGS+=("${CMAKE_EXTRA[@]}")

echo "==> cmake configure ($BV2_PLATFORM) -> $BUILD"
cmake "${CMAKE_ARGS[@]}"

echo "==> cmake build ($BV2_PLATFORM)"
cmake --build "$BUILD" \
	--target BaboMasterServer BaboViolentDedicated BaboViolent \
	-j"$(nproc 2>/dev/null || echo 4)"

echo "==> built:"
ls -la "$BUILD"/BaboMasterServer* "$BUILD"/BaboViolent* 2>/dev/null || true
