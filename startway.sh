#!/bin/sh

# Exports:
export GTK2_RC_FILES=$HOME/.gtkrc-2.0
export GTK_IM_MODULE=xim
export _JAVA_AWT_WM_NONREPARENTING=1
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1

exec dbus-launch --exit-with-session ssh-agent sway