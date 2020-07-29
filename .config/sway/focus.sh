#!/bin/sh -e

tree=$(swaymsg -t get_tree)

current_workspace=$(echo "$tree" | jq '.nodes | .[1].current_workspace')

# Get all the available windows in the workspace
unfocused_containers=$(echo "$tree" | jq ".nodes | .[1].nodes | .[] | select(if .name == $current_workspace then . else null end) | ..|.nodes? | .[]? | if .pid then .id else null end | select(.)" | sort -g)

current_container=$(echo "$tree" | jq ".nodes | .[1].nodes | .[] | select(if .name == $current_workspace then . else null end) | ..|.nodes? | .[]? | if .focused then .id else null end | select(.)")

next_container=$(echo "$unfocused_containers" | head -n 1)
for id in $unfocused_containers; do
  if [ $id -gt $current_container ]; then
    next_container=$id
    break
  fi
done

if [ -n $next_container ]; then
  swaymsg "[con_id=$next_container]" focus
fi
