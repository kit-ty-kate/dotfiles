#!/bin/sh

set -e

get_inode() {
    stat -Lc "%i" "$1"
}

is_installed() {
    inode_src=$(get_inode "$1")
    inode_dst=$(get_inode "$2" 2> /dev/null || true)

    test "$inode_src" = "$inode_dst"
}

inst() {
    src=$(pwd)/$1
    dst=$HOME/$1
    if ! is_installed "$src" "$dst"; then
        if test -e "$dst"; then
            echo "'$1' already exists and is not the same file"
        else
            ln -i "$src" "$dst"
            echo "'$1' installed"
        fi
    fi
}

inst_systemd_user_service() {
    service=$1.service
    if systemctl --version > /dev/null; then
        inst ".config/systemd/user/$service"
        if ! systemctl is-enabled --user "$service" > /dev/null; then
            systemctl enable --user "$service"
        fi
    fi
}

distribution=$(grep '^ID=' /etc/os-release | cut -d= -f2) || true

test_inst_pkg() {
    pkg=$1
    if test "$distribution" = "debian"; then
        if ! dpkg -s "$pkg" > /dev/null 2> /dev/null; then
            echo "System package '$pkg' is not installed."
        fi
    else
        echo "Could not test if '$pkg' is installed."
    fi
}

test_inst_bin() {
    bin=$1
    url=$2
    if ! which "$bin" > /dev/null; then
        echo "'$pkg' is not installed and is not available on your system."
        echo "Source: $url"
    fi
}

set_default_app() {
    action=$1
    app=$2.desktop
    if test "$(xdg-settings get '$action')" = "$app"; then
        xdg-settings set "$action" "$app"
    fi
}

# Not used anymore
#inst .config/vimfx/config.js
#inst .config/vimfx/frame.js
#inst .config/xmobar/battery.sh
#inst .config/xmobar/pavolume.sh
#inst .config/xmobar/trayer-padding-icon.sh
#inst .config/xmobar/xmobarrc
#inst .xmonad/brightness.sh
#inst .xmonad/xmonad.hs
#inst .XCompose
#inst .xinitrc
#inst startway.sh

inst .config/sway/config
inst .config/sway/focus.sh
inst .config/waybar/config
inst .config/waybar/style.css
inst .config/mako/config
inst .emacs.d/init.el
inst .gitconfig
inst .ocamlinit
inst .ocp/ocp-indent.conf
inst .vim/plugin/vimspell.vim
inst .vim/vimrc
inst .zshrc

inst_systemd_user_service ssh-agent

# Test for program used above
#test_inst_pkg vim
#test_inst_pkg emacs-nox
#test_inst_pkg sway
#test_inst_pkg waybar
#test_inst_pkg xwayland
#test_inst_pkg firefox
#test_inst_pkg gnome-terminal
#test_inst_pkg git
#test_inst_pkg zsh
#test_inst_pkg openssh-client
#test_inst_bin opam "git://github.com/kit-ty-kate/opam.git#opam-health-check3"

# mako is a notification utility for wayland
#test_inst_pkg mako-notifier
#test_inst_pkg network-manager-gnome
# Copy/Paste handler for wayland
#test_inst_pkg wl-clipboard
#test_inst_pkg clipman
# suckless-tools contains dmenu used in .config/sway/exec.sh
#test_inst_pkg suckless-tools
# slurp & grim are screenshot tools for wayland
#test_inst_pkg slurp
#test_inst_pkg grim
# Redshift for wayland
#test_inst_bin gammastep-indicator "https://gitlab.com/chinstrap/gammastep"

#set_default_app default-web-browser firefox

echo 'Done.'
