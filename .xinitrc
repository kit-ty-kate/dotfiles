#!/bin/sh

# Exports:
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GTK_IM_MODULE=xim
export _JAVA_AWT_WM_NONREPARENTING=1

# Language-specific package managers configuration
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.cabal/bin"

cmd () {
    hash "$1" || exit 1
    $@ &
}

# Compositor
cmd compton --backend glx --vsync opengl-swc --sw-opti --vsync-aggressive

# Num. Lock:
cmd numlockx

# Clipboard
cmd parcellite --no-icon

# Screen lock
cmd gnome-screensaver

# Keyboard layout
cmd setxkbmap fr bepo

# Background
cmd feh --bg-center pictures/bg.png

# Notification tool
cmd trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype request --height 17 --transparent true --alpha 0 --tint 0x000000

# WM (wrapped with dbus & ssh-agent):
#exec dbus-launch --exit-with-session ssh-agent awesome
exec dbus-launch --exit-with-session ssh-agent xmonad
