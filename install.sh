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
            echo "[ERROR] '$1' already exists and is not the same file"
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

set_default_app() {
    action=$1
    app=$2.desktop
    if test "$(xdg-settings get '$action')" = "$app"; then
        xdg-settings set "$action" "$app"
    fi
}

inst_modprobe_conf() {
    src=$(pwd)/$1
    dst=/$1
    if ! is_installed "$src" "$dst"; then
        if test -e "$dst"; then
            echo "'$1' already exists and is not the same file"
        else
            sudo chown root:root "$src"
            sudo ln -i "$src" "$dst"
            sudo mkinitcpio -P
            echo "'$1' installed"
        fi
    fi
}

cmd_is_here() {
  if ! command -v "$1" > /dev/null ; then
    echo "[ERROR] '$1' not found."
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
inst .config/terminator/config
inst .emacs.d/init.el
inst .gitconfig
inst .ocamlinit
inst .ocp/ocp-indent.conf
inst .vim/plugin/vimspell.vim
inst .vim/vimrc
inst .zshrc

inst .local/bin/upgrade_opam
inst .local/bin/git_pr
inst .local/bin/git_rebase_continue_except
inst .local/bin/encode
inst .local/bin/decode

inst_systemd_user_service ssh-agent
inst_systemd_user_service set-moz-gmp-path

#inst_modprobe_conf etc/modprobe.d/hid_apple.conf

cmd_is_here vim
cmd_is_here emacs
cmd_is_here sway
cmd_is_here waybar
cmd_is_here firefox
cmd_is_here terminator
cmd_is_here git
cmd_is_here zsh
cmd_is_here ssh
cmd_is_here opam
cmd_is_here swayidle
cmd_is_here grim
cmd_is_here slurp
cmd_is_here waylaunch
cmd_is_here mako
cmd_is_here nm-applet
cmd_is_here blueman-applet
cmd_is_here gammastep-indicator
cmd_is_here openssl

#set_default_app default-web-browser firefox

echo 'Done.'
