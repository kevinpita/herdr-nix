#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ $# -gt 1 || ( $# -eq 1 && $1 != --check ) ]]; then
    echo 'Usage: update-config-reference.sh [--check]' >&2
    exit 2
fi
source=$(nix build "path:$PWD#herdr.src" --no-link --print-out-paths)
reference="$source/docs/next/website/src/data/config-reference.json"
if [[ ${1:-} == --check ]]; then
    cmp "$reference" data/config-reference.json
else
    cp "$reference" data/config-reference.json
    echo 'Review option types and examples, render docs/settings.md, then run nix flake check.'
fi
