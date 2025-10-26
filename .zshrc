# shellcheck shell=zsh

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zmodload zsh/zprof
fi

# Exit if not interactive shell
[[ $- != *i* ]] && return

#######
# Zinit
#######

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

source "${ZINIT_HOME}/zinit.zsh"

# Load all the auto-completions, has to be done before any compdefs
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Required plugins
zinit light-mode for \
    mroth/evalcache

# Optional plugins
zinit wait light-mode lucid for \
    OMZL::completion.zsh \
    OMZL::directories.zsh \
    OMZL::git.zsh \
    OMZL::history.zsh \
    OMZL::key-bindings.zsh \
    OMZP::1password \
    OMZP::ansible \
    OMZP::aws \
    OMZP::docker \
    OMZP::docker-compose \
    OMZP::doctl \
    OMZP::fancy-ctrl-z \
    OMZP::fzf \
    OMZP::gh \
    OMZP::git \
    OMZP::golang \
    OMZP::history \
    OMZP::jsontools \
    OMZP::kubectl \
    OMZP::terraform \
    OMZP::uv \
    MichaelAquilina/zsh-you-should-use \
    zdharma-continuum/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        @zsh-users/zsh-autosuggestions
    # jeffreytse/zsh-vi-mode

# Load completions after plugins
mkdir -p ~/.cache/zinit/completions
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
    zinit ice lucid atinit"zicompinit; zicdreplay"
    compinit -C
else
    zinit ice lucid atinit"zicompinit; zicdreplay"
    compinit
fi
zinit cdreplay -q

#####
# ZSH
#####

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

# Node tools
alias cdk="npx --yes aws-cdk@latest"
alias claude="npx --yes anthropic-ai/claude-code@latest"
alias iam-convert="npx --yes @cloud-copilot/iam-convert"
alias iam-expand="npx --yes @cloud-copilot/iam-expand"
alias iam-shrink="npx --yes @cloud-copilot/iam-shrink"
alias wrangler="npx --yes wrangler@latest"
alias copilot="npx --yes @github/copilot"

# Python tools
alias awslocal="uvx --from awscli-local awslocal"
alias custodian="uvx --from c7n custodian"
alias octodns-dump="uvx --with octodns-route53 --with octodns-cloudflare --from octodns octodns-dump"
alias octodns-sync="uvx --with octodns-route53 --with octodns-cloudflare --from octodns octodns-dump"
alias samlocal="uvx --from aws-sam-cli-local samlocal"
alias tflocal="uvx --from terraform-local tflocal"
alias wafw00f="uvx wafw00f"

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
export TERRAGRUNT_LOCAL="true"
export TF_PLUGIN_CACHE_DIR="$HOME/.terragrunt/plugins"
export TG_DOWNLOAD_DIR="$HOME/.terragrunt/cache"
export TG_LOCAL="true"
export TG_LOG_DISABLE="true"

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
    path=(
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
        echo "${path[*]}"
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

eval_ondir() {
  eval "`ondir \"$OLDPWD\" \"$PWD\"`"
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
    # source "$HOME"/.config/op/plugins.sh
    export OP_PLUGIN_ALIASES_SOURCED=1
    alias gh="op plugin run -- gh"
    alias doctl="op plugin run -- doctl"
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

# Additional completions
fpath=(~/.cache/zinit/completions $ZSH/functions $ZSH/completions $fpath)

# Allow autocomplete for aliases
setopt complete_aliases

# Ondir configuration
# chpwd_functions=(eval_ondir $chpwd_functions)

###############
# Shell startup
###############

# Init
_evalcache starship init zsh
_evalcache zoxide init zsh
_evalcache thefuck --alias f -y
_evalcache mise activate zsh

if [ -n "${ZSH_DEBUGRC+1}" ]; then
    zprof | head -n 40
fi
