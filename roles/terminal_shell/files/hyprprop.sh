#!/usr/bin/env sh
# wlprop equivalent for Hyprland
set -eu

TREE="$(hyprctl clients -j | jq -c '.[] | select(.hidden==false and .mapped==true)')"
SELECTION="$(printf '%s\n' "$TREE" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)"

X="$(printf '%s\n' "$SELECTION" | awk -F'[, x]' '{print $1}')"
Y="$(printf '%s\n' "$SELECTION" | awk -F'[, x]' '{print $2}')"
W="$(printf '%s\n' "$SELECTION" | awk -F'[, x]' '{print $3}')"
H="$(printf '%s\n' "$SELECTION" | awk -F'[, x]' '{print $4}')"

printf '%s\n' "$TREE" | jq -r --argjson x "$X" --argjson y "$Y" --argjson w "$W" --argjson h "$H" \
  '. | select(.at[0]==$x and .at[1]==$y and .size[0]==$w and .size[1]==$h)'
