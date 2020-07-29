#!/bin/sh -e

history_log=$HOME/.config/sway/cmd-history
history_limit=50

touch "$history_log"

cmd_history=$(cat "$history_log")
cmd_available=$(dmenu_path)
cmd_available=$(echo "$cmd_available")

cmds="$cmd_available"

if [ -n "$cmd_history" ]; then
  cmds="$cmd_history\n$cmds"
  cmd_history="\n$cmd_history"
fi

cmd=$(echo "$cmds" | sort -u | dmenu -l 5)
cmd_test=$(echo "$cmd" | cut -d' ' -f1)

# Save command if is a valid command
if command -v "$cmd_test" > /dev/null 2>&1; then
    cmd_history=$(echo "$cmd_history" | grep -Fvx "$cmd")
    echo "$cmd$cmd_history" | head -n $history_limit > "$history_log"
fi

exec swaymsg exec -- $cmd
