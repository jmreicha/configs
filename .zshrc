# shellcheck shell=zsh

#####
# ZSH
#####

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# Exit if not interactive shell
[[ $- != *i* ]] && return

# Path to oh-my-zsh installation if not using Nix.
if [[ -z "$NIX" ]]; then
    export ZSH=$HOME/.oh-my-zsh
fi

# Disable theme since we are using starship
ZSH_THEME=""

# Skip insecure directory permissions check to speed up start time
ZSH_DISABLE_COMPFIX="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Disable automatic text highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/issues/349
zle_highlight+=(paste:none)

# Zsh autosuggestion highlighting - grey
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# WARNING: `source ~/.zshrc` becomes unusable with the zsh-syntax-highlighting plugin
plugins=(
    1password
    ansible
    aws
    docker
    docker-compose
    doctl
    extract
    evalcache
    fancy-ctrl-z
    gh
    git
    golang
    history
    jsontools
    kubectl
    terraform
    uv
    zsh-vi-mode
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-you-should-use
)

# Load here to be able to source extra plugins and configurations like zsh-autosuggestions and zsh-syntax-highlighting
source "$ZSH"/oh-my-zsh.sh

# Ensure paths are loadded the same way every time
fpath=(${(uo)fpath})

# Unlimited history
HIST_STAMPS="mm/dd/yyyy"
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=$HISTSIZE
# Ignore duplictates in history file
setopt HIST_IGNORE_ALL_DUPS

#########
# Aliases
#########

# AWS
alias av="aws-vault"

# Docker
alias d="docker"
alias dc="docker-compose"

# Eza
alias l='eza -lbGF --git'
alias la='eza -lbhHigmuSa --time-style=long-iso --git --color-scale'
alias ld='eza -lD'
alias ldd='eza -laD'
alias ll='eza --group --header --group-directories-first --long'
alias ls='eza -a --icons'
alias lt='eza --tree --level=2'

# Kubernetes
alias kctx="kubectx"
alias kns="kubens"
alias ktop="k9s -n all"

# Misc
alias bat="bat --number"
alias cat="bat --style=plain --paging=never"
alias diff="colordiff -u"
alias e="exit"
alias ff="fzf --preview 'bat {} --color=always --style=numbers --theme=1337'"
alias gld="git log -p --ext-diff"
alias python="python3"
alias q="chatblade"
alias rg="rg --hidden -g '!.git/'"
alias v='vim +'"'"'normal! g`"'"'"
alias vv="vim ~/.vimrc"
alias zperf='time ZSH_DEBUGRC=1 zsh -i -c exit'
alias zz="vim ~/.zshrc"

# Terraform
alias tf="terraform"
alias tg="terragrunt"

#########
# Exports
#########

# Aqua
export AQUA_DISABLE_POLICY=true

# AWS
export AWS_PAGER=""
# export AWS_ASSUME_ROLE_TTL="1h"
# export AWS_CSM_ENABLED=true
# export AWS_CSM_PORT=31000
# export AWS_CSM_HOST=127.0.0.1
# export AWS_SESSION_TTL="12h"

# FZF
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git/*"'
export FZF_CTRL_T_COMMAND='rg --files --hidden -g "!.git/*"'

# GPG key
export GPG_TTY=$(tty)
# export SOPS_PGP_FP="2AF2A2053D553C2FAE789DD6A9752A813F1EF110"

# Goenv
export GOENV_ROOT="$HOME/.goenv"

# HSTR
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm

# Kubernetes
export KUBECTL_EXTERNAL_DIFF=colordiff

# Language - force to utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# OpenAI
export OPENAI_API_KEY=

# Python
export PYTHON_AUTO_VRUN=true
export PYTHON_VENV_NAME=".venv"

# Terraform/Terragrunt - set cache in one place
export TF_PLUGIN_CACHE_DIR="$HOME/.terragrunt/plugins"
export TERRAGRUNT_DOWNLOAD="$HOME/.terragrunt/cache"
export TERRAGRUNT_LOCAL="true"

# SSH
export SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Terminal
export TERM="xterm-256color"

# Zoxide
export _ZO_FZF_OPTS="--height 40%"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='vim'
fi

######
# PATH
######

if [[ -z "$__PATH_SET" ]]; then
    paths=(
        "/opt/homebrew/bin"
        "/usr/local/bin"
        "${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/aquaproj-aqua}/bin"
        "${GOENV_ROOT}/bin"
        "${HOME}/.local/bin"
        "${HOME}/.local/share"
        "${HOME}/.tgenv/bin"
        "${HOME}/bin"
        "${KREW_ROOT:-${HOME}/.krew}/bin"
        "${PATH}"
    )

    # Join the paths into colon separated string and export
    export PATH=$(
        IFS=:
        echo "${paths[*]}"
    )
    # Ensure PATH only gets set once
    export __PATH_SET=1
fi

###########
# Functions
###########

# Clear docker containers, images and volumes
dclean() {
    docker rm "$(docker ps -aq --filter status=exited)"
    docker rmi "$(docker images -q --filter dangling=true)"
    docker volume rm "$(docker volume ls -qf dangling=true)"
}

# Lazy-load goenv
function load_goenv() {
    eval "$(goenv init -)"
    unset -f load_goenv
}

# Only run goenv init before a Go command
function go() {
    load_goenv
    command go "$@"
}

#############
# OS Specific
#############

### OSX
if [[ $(uname) == "Darwin" ]]; then
    alias pinentry='pinentry-mac'

    # Retrieve a secret from osx keychain
    get_secret() {
        security find-generic-password -gs "${1}" -w
    }

    # 1password
    source "$HOME"/.config/op/plugins.sh

    plugins+=(osx)
fi

### Linux
if [[ $(uname) == "Linux" ]]; then
    alias ip="ip -c"

    # OS specific configs
    if grep ID=debian /etc/os-release >/dev/null; then
        alias fd="fdfind --hidden"
    else
        alias fd="fd --hidden"
    fi

    FNM_PATH="/home/jmreicha/.local/share/fnm"
    if [ -d "$FNM_PATH" ]; then
        export PATH="/home/jmreicha/.local/share/fnm:$PATH"
    fi

    # Credentials are stored in gpg/pass in non container envs
    if [[ $REMOTE_CONTAINERS = "true" ]]; then
        export AWS_VAULT_BACKEND="file"
    else
        export AWS_VAULT_BACKEND="pass"
    fi

    # Retrieve a secret from pgp pass backend
    get_secret() {
        pass show "$1"
    }
fi

# plugins+=(zsh-autosuggestions zsh-syntax-highlighting)

#####################
# Misc Configurations
#####################

# zsh-vim-mode
ZVM_CURSOR_STYLE_ENABLED=false
ZVM_VI_HIGHLIGHT_BACKGROUND=#505050
ZVM_VI_INSERT_ESCAPE_BINDKEY=";;"
ZVM_KEYTIMEOUT=0.03

# Bash hotkey for end of line kill
bindkey \^U backward-kill-line

# kubectx/kubens completions
fpath=($ZSH/functions $ZSH/completions $fpath)

# Allow autocomplete for aliases
setopt complete_aliases

# FZF (assume ripgrep is installed)
zvm_after_init_commands+=('source <(fzf --zsh)')

###############
# Shell startup
###############

# Ondir configuration
# eval_ondir() {
#   eval "`ondir \"$OLDPWD\" \"$PWD\"`"
# }

# chpwd_functions=(eval_ondir $chpwd_functions)

# Init
# eval "$(starship init zsh)"
# eval "$(zoxide init zsh)"
# eval "$(thefuck --alias f -y)"
# eval "$(goenv init -)"
# eval "$(direnv hook zsh)"
# eval "$(fnm env --use-on-cd --shell zsh)"

_evalcache starship init zsh
_evalcache zoxide init zsh
_evalcache thefuck --alias f -y
# _evalcache goenv init -
_evalcache direnv hook zsh
_evalcache fnm env --use-on-cd --shell zsh

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof
fi
