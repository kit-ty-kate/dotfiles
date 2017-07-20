#!/bin/sh

# Exports:
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export GTK_IM_MODULE=xim
export _JAVA_AWT_WM_NONREPARENTING=1

# Compositor
compton --backend glx --vsync opengl-swc --sw-opti --vsync-aggressive &

# Num. Lock:
numlockx &

# xmodmap
xmodmap ~/.Xmodmap &

# Clipboard
parcellite -d &

# Zlock
xscreensaver -no-splash &

# Pidgin (netsoul)
#pidgin &

# Keyboard layout
setxkbmap fr bepo &

# Background
feh --bg-center pictures/bg.png &

# ssh-agent
eval `ssh-agent`

# DBus
eval `dbus-launch --sh-syntax --exit-with-session`

# Notification tool
trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --widthtype request --height 17 --transparent true --tint 0x000000 &

# Network manager
nm-applet &

# Redshift
redshift-gtk -l `head -n 1 ~/.location` &

# WM:
#exec awesome
exec xmonad
