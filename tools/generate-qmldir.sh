#!/usr/bin/env bash

set -e

usage() {
  echo "Usage: $0 <qml-directory> <module-name> [module-version]" >&2
  echo "  module-version defaults to 1.0" >&2
  exit 1
}

QML_DIR="${1:-}"
MODULE="${2:-}"
VERSION="${3:-1.0}"

# Validate args
if [ -z "$QML_DIR" ] || [ -z "$MODULE" ]; then
  usage
fi

if [ ! -d "$QML_DIR" ]; then
  echo "Error: '$QML_DIR' is not a directory." >&2
  exit 1
fi

OUT_FILE="$QML_DIR/qmldir"

tmpfile="$(mktemp)"

# Module header
printf 'module %s\n\n' "$MODULE" > "$tmpfile"

# Collect .qml files directly inside the directory (no recursion)
shopt -s nullglob
files=("$QML_DIR"/*.qml)
shopt -u nullglob

if [ ${#files[@]} -eq 0 ]; then
  echo "Warning: no .qml files found directly in '$QML_DIR'." >&2
  mv "$tmpfile" "$OUT_FILE"
  echo "Wrote minimal $OUT_FILE"
  exit 0
fi

# Sort
IFS=$'\n' sorted=($(for f in "${files[@]}"; do basename "$f"; done | sort))
unset IFS

# Emit entries
for bn in "${sorted[@]}"; do
  typename="${bn%.qml}"
  printf '%s %s %s\n' "$typename" "$VERSION" "$bn" >> "$tmpfile"
done

mv -- "$tmpfile" "$OUT_FILE"
echo "Generated $OUT_FILE (module=$MODULE, version=$VERSION)"
