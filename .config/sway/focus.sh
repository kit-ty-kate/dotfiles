#!/bin/sh -e

tree=$(mktemp)
swaymsg -t get_tree >> "$tree"

current_workspace=$(cat "$tree" | jq '.nodes | .[1].current_workspace')

# Get all the available windows in the workspace
unfocused_containers=$(cat "$tree" | jq ".nodes | .[1].nodes | .[] | select(if .name == $current_workspace then . else null end) | ..|.nodes? | .[]? | if .pid then .id else null end | select(.)" | sort -g)

current_container=$(cat "$tree" | jq ".nodes | .[1].nodes | .[] | select(if .name == $current_workspace then . else null end) | ..|.nodes? | .[]? | if .focused then .id else null end | select(.)")

next_container=$(echo "$unfocused_containers" | head -n 1)
for id in $unfocused_containers; do
  if test "$id" -gt "$current_container"; then
    next_container=$id
    break
  fi
done

if test -n $next_container; then
  swaymsg "[con_id=$next_container]" focus
fi

rm -f "$tree"
