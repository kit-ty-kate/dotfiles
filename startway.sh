#!/bin/sh

# Exports:
export GTK2_RC_FILES=$HOME/.gtkrc-2.0
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1

# Fix tray icons
export XDG_CURRENT_DESKTOP=Unity

exec dbus-launch --exit-with-session sway
