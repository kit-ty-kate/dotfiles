#!/bin/sh -e

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

# Not used anymore
#inst .config/vimfx/config.js
#inst .config/vimfx/frame.js

inst .XCompose
inst .config/xmobar/battery.sh
inst .config/xmobar/pavolume.sh
inst .config/xmobar/trayer-padding-icon.sh
inst .config/xmobar/xmobarrc
inst .config/sway/config
inst .config/sway/exec.sh
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
inst .xinitrc
inst .xmonad/brightness.sh
inst .xmonad/xmonad.hs
inst .zshrc
inst startway.sh

inst_systemd_user_service ssh-agent

echo 'Done.'
