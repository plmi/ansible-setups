#!/usr/bin/env sh
set -eu

TARGET_FILE="${HOME}/.target"

usage() {
  cat <<'EOF'
Usage:
  target <ip-or-name>   Set current target
  target --show         Show current target
  target --clear        Clear current target
EOF
}

case "${1:-}" in
  --show|-s)
    if [ -f "$TARGET_FILE" ]; then
      head -n1 "$TARGET_FILE"
    else
      echo "unset"
    fi
    exit 0
    ;;
  --clear|-c)
    printf 'unset\n' > "$TARGET_FILE"
    echo "Target cleared"
    exit 0
    ;;
  --help|-h|"")
    usage
    exit 0
    ;;
esac

printf '%s\n' "$1" > "$TARGET_FILE"
echo "Target set: $1"
