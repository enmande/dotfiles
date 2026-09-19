#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-$HOME}"

echo "Scanning for broken symlinks in $TARGET (maxdepth 6)..."
echo ""

count=0
removed=0

while IFS= read -r link; do
  count=$((count + 1))
  target="$(readlink "$link")"
  printf "  Broken: %s\n  → %s\n  Remove? [y/N] " "$link" "$target"
  read -r confirm < /dev/tty
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm "$link"
    echo "  Removed."
    removed=$((removed + 1))
  else
    echo "  Skipped."
  fi
  echo ""
done < <(find "$TARGET" -maxdepth 6 -type l ! -e 2>/dev/null | sort)

if [[ $count -eq 0 ]]; then
  echo "No broken symlinks found."
else
  echo "Done. Removed $removed of $count broken symlinks."
fi
