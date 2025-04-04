#####
# ZSH
#####

# Path to oh-my-zsh installation if not using Nix.
if [[ -z "$NIX" ]]; then
    export ZSH=$HOME/.oh-my-zsh
fi

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
    fancy-ctrl-z
    fzf
    gh
    git
    golang
    history
    jsontools
    kubectl
    nvm
    pip
    python
    terraform
    uv
    virtualenv
    zsh-vi-mode
    zsh-autosuggestions
    zsh-nvm
    zsh-syntax-highlighting
    zsh-you-should-use
)

# Load here to be able to source extra plugins and configurations like zsh-autosuggestions and zsh-syntax-highlighting
source "$ZSH"/oh-my-zsh.sh

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

# Misc
alias gld="git log -p --ext-diff"
alias cat="bat --style=plain --paging=never"
alias bat="bat --number"
# Attempt to open vim to previous edit
alias v='vim +'"'"'normal! g`"'"'"
alias zz="vim ~/.zshrc"
alias vv="vim ~/.vimrc"
alias diff="colordiff -u"
alias e="exit"
alias ff="fzf --preview 'bat {} --color=always --style=numbers --theme=1337'"
alias python="python3"
alias q="chatblade"
alias rg="rg --hidden -g '!.git/'"

# Docker
alias d="docker"
alias dc="docker-compose"

# Kubernetes
alias kctx="kubectx"
alias kns="kubens"
alias ktop="k9s -n all"

# Terraform
alias tf="terraform"
alias tg="terragrunt"

# AWS
alias av="aws-vault"

# Eza
alias ld='eza -lD'
alias ldd='eza -laD'
alias ls='eza -a --icons'
alias ll='eza --group --header --group-directories-first --long'
alias l='eza -lbGF --git'
alias la='eza -lbhHigmuSa --time-style=long-iso --git --color-scale'
alias lt='eza --tree --level=2'

#########
# Exports
#########

# Bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export PAGER="/opt/homebrew/bin/bat"

# Node
export NVM_COMPLETION=true

# Python
export PYTHON_VENV_NAME=".venv"
export PYTHON_AUTO_VRUN=true

# Aqua
export PATH=${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH
export AQUA_DISABLE_POLICY=true

# OpenAI
export OPENAI_API_KEY=

# GPG key
export GPG_TTY=$(tty)
# export SOPS_PGP_FP="2AF2A2053D553C2FAE789DD6A9752A813F1EF110"

# Goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"

# Better terminal colors
export TERM="xterm-256color"

# Set default kubernetes diff
export KUBECTL_EXTERNAL_DIFF=colordiff

# AWS
export AWS_PAGER=""
# export AWS_ASSUME_ROLE_TTL="1h"
# export AWS_CSM_ENABLED=true
# export AWS_CSM_PORT=31000
# export AWS_CSM_HOST=127.0.0.1
# export AWS_SESSION_TTL="12h"

# Krew k8s package manager
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Home user bin directory
export PATH="$HOME/bin:$PATH"

# Bin
export PATH="/usr/local/bin:$PATH"

# hstr
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm

# Export SSH key so it doesn't need to be passed in every time.
export SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# Set the terraform/terragrunt cache in one place
export TF_PLUGIN_CACHE_DIR="$HOME/.terragrunt/plugins"
export TERRAGRUNT_DOWNLOAD="$HOME/.terragrunt/cache"
export TERRAGRUNT_LOCAL="true"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='vim'
fi

# Force the language environment to utf-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Zoxide
export _ZO_FZF_OPTS="--height 40%"

###########
# Functions
###########

dclean() {
    docker rm "$(docker ps -aq --filter status=exited)"
    docker rmi "$(docker images -q --filter dangling=true)"
    docker volume rm "$(docker volume ls -qf dangling=true)"
}

#############
# OS Specific
#############

### OSX
if [[ $(uname) == "Darwin" ]]; then
    echo "Loading additional OSX configuration"

    alias pinentry='pinentry-mac'

    # Retrieve a secret from osx keychain
    get_secret() {
        security find-generic-password -gs "${1}" -w
    }

    # Python3
    export PATH=$PATH:/$HOME/Library/Python/3.9/bin/
    # Homebrew
    export PATH="/opt/homebrew/bin:$PATH"
    # tgenv
    export PATH="$HOME/.tgenv/bin:$PATH"

    # 1password
    source "$HOME"/.config/op/plugins.sh

    plugins+=(osx)
fi

### Linux
if [[ $(uname) == "Linux" ]]; then
    echo "Loading additional Linux configuration"

    alias ip="ip -c"

    # OS specific configs
    if grep ID=debian /etc/os-release; then
        alias fd="fdfind --hidden"
        export PATH=$PATH:/$HOME/.local/bin
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

###############
# Shell startup
###############

# Allow autocomplete for aliases
setopt complete_aliases

# FZF (assume ripgrep is installed)
zvm_after_init_commands+=('source <(fzf --zsh)')
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git/*"'
export FZF_CTRL_T_COMMAND='rg --files --hidden -g "!.git/*"'

# Ondir configuration
# eval_ondir() {
#   eval "`ondir \"$OLDPWD\" \"$PWD\"`"
# }

# chpwd_functions=(eval_ondir $chpwd_functions)

# Init
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias f -y)"
eval "$(goenv init -)"
eval "$(direnv hook zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"
