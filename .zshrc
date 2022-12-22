# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
HISTTIMEFORMAT="[%F %T] "
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Completion
autoload -U compinit
compinit
zstyle ':completion:*' menu select
setopt completealiases
zmodload zsh/complist
compdef -d java

# Uniquness completions
zstyle ':completion:*:rm:*' ignore-line yes
zstyle ':completion:*:mv:*' ignore-line yes
zstyle ':completion:*:cp:*' ignore-line yes

# Bash completion
autoload -U bashcompinit
bashcompinit

# Colors
autoload -U colors
colors

# Completion for kill
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors "=(#b) #([0-9]#)*=36=31"

# Auto cd
setopt autocd

# Variables
export MANPAGER=most
export EDITOR=vim
export ZSH_GIT=1

# Make Firefox pretty on Sway
export MOZ_ENABLE_WAYLAND=1

# ssh-agent (setup by systemd)
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

# Language-specific package managers configuration
export PATH=$PATH:$HOME/.cargo/bin
export PATH=$PATH:$HOME/.cabal/bin

# Aliases
alias emacs="emacs -nw --no-site-file --no-splash"
alias ls="ls --color"
alias grep='grep --color=auto'
alias pcat='pygmentize'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias chloc='vim ~/.location && sudo vim /etc/apt/sources.list && sudo dpkg-reconfigure tzdata'
alias flacky-scp='rsync --progress --inplace'
alias cal='cal -mw'

# Functions
function mkcd {
    mkdir "$1" && cd "$1"
}

function weather {
    local loc=${1:-`head -n 1 ~/.location | tr ':' ','`}
    curl "wttr.in/$loc"
}

function play {
    cvlc --no-xlib $@ vlc://quit
}

function vimpatch {
    vim "$1" "+vertical diffpatch $2"
}

function opam_cache {
    local hash_fun=$(echo "$1" | cut -d= -f 1)
    local archive_hash=$(echo "$1" | cut -d= -f 2)
    local first_two=${archive_hash:0:2}
    echo https://opam.ocaml.org/cache/${hash_fun}/${first_two}/${archive_hash}
}

function git_fork {
    local username=$(echo "$1" | cut -d: -f1)
    local branch=$(echo "$1" | cut -d: -f2)
    local repository=$(basename "$(git rev-parse --show-toplevel)")
    if ! (git remote | grep -q "^$username\$"); then
        git remote add "$username" "git@github.com:$username/$repository.git"
    fi
    git fetch "$username" "$branch"
    if ! git switch -c "$branch" "$username/$branch"; then
      git switch "$branch"
      git pull --ff-only "$username" "$branch"
    fi
}

function git_mine {
    local repository=$(basename "$(git rev-parse --show-toplevel)")
    git remote add mine "git@github.com:kit-ty-kate/$repository.git"
}

# Prompt
autoload -U promptinit
promptinit
prompt adam2

setopt prompt_subst

GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}Ahead by NUM%{$reset_color%} "
GIT_PROMPT_BEHIND="%{$fg[cyan]%}Behind by NUM%{$reset_color%} "
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"

parse_git_branch() {
    (git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD) 2> /dev/null
}

parse_git_state() {
    local GIT_STATE=""
    local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_AHEAD" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
    fi
    local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
    if [ "$NUM_BEHIND" -gt 0 ]; then
        GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
    fi
    local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
    if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
    fi
    local GIT_STATUS="$(git status --short)"
    if [[ -n $(echo "$GIT_STATUS" | grep "^??") ]]; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
    fi
    if [[ -n $(echo "$GIT_STATUS" | grep "^ M") ]]; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
    fi
    if [[ -n $(echo "$GIT_STATUS" | grep "^M ") ]]; then
        GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
    fi
    if [[ -n $GIT_STATE ]]; then
        echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
    fi
}

egit() {
    if [ "$ZSH_GIT" = 1 ]; then
        unset ZSH_GIT
    else
        export ZSH_GIT=1
    fi
}

git_prompt_string() {
    if [ -z $ZSH_GIT ]; then; return; fi
    local git_where="$(parse_git_branch)"
    [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
}

parse_opam_state() {
    local state="`grep "^switch:" ~/.opam/config | awk 'NB == 0 { print $2 }'`"
    echo ${state//\"/}
}

opam_prompt_string() {
    if [ -d ~/.opam ]; then
        local state=$(parse_opam_state)
        if [ -z "`echo $PATH | grep "$state"`" ]; then
            echo "$GIT_PROMPT_PREFIX%{$fg[red]%}$state$GIT_PROMPT_SUFFIX"
        else
            echo "$GIT_PROMPT_PREFIX$state$GIT_PROMPT_SUFFIX"
        fi
    fi
}

RPS1='$(git_prompt_string)$(opam_prompt_string)'

# Key Bindings
bindkey -e
bindkey "^H" run-help

# Key Bindings from the archlinux wiki
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       history-search-backward
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     history-search-forward
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
bindkey "\e[Z" reverse-menu-complete
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char

# Custom file
test -r ~/.zshrc_aliases && source ~/.zshrc_aliases

# opam configuration
[[ ! -r "$HOME/.opam/opam-init/init.zsh" ]] || source "$HOME/.opam/opam-init/init.zsh" > /dev/null 2> /dev/null
