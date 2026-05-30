#!/usr/bin/env bash
# Backward-compatible wrapper — produces the same three Linux packages as
# scripts/package-release.sh (tar.gz by default; legacy zip names removed).
#
# Usage (from repo root):
#   ./scripts/package-linux-distributions.sh

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export BUILD="${BUILD:-$ROOT/build}"
export BV2_PLATFORM=linux
export BV2_ARCHIVE=tar.gz
exec bash "$ROOT/scripts/package-release.sh"
