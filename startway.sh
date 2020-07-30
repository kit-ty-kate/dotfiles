#!/bin/sh

# Exports:
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GTK_IM_MODULE=xim
export _JAVA_AWT_WM_NONREPARENTING=1

# Language-specific package managers configuration
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.cabal/bin"

exec dbus-launch --exit-with-session ssh-agent sway
