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
    kube-ps1
    kubectl
    nvm
    pip
    python
    terraform
    uv
    virtualenv
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

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

#########
# Aliases
#########

# Misc
alias cat="bat --style=plain --paging=never"
alias bat="bat --paging=never"
alias diff="colordiff -u"
alias e="exit"
alias ff="fzf --preview 'bat {} --color=always --style=numbers --theme=1337'"
alias python="python3"
alias q="chatblade"
alias rg="rg --hidden -g '!.git/'"
alias v="vim ~/.vimrc"
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias zz="vim ~/.zshrc"

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
alias ao="aws-okta"

# Eza
alias ld='eza -lD'
alias ldd='eza -laD'
alias ls='eza -a'
alias ll='eza --group --header --group-directories-first --long'
alias l='eza -lbGF --git'
alias la='eza -lbhHigmuSa --time-style=long-iso --git --color-scale'
alias lt='eza --tree --level=2'

#########
# Exports
#########

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

# GO
export PATH=$PATH:/usr/local/go/bin:$PATH:$GOROOT/bin:$GOPATH/bin

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
# export AWS_SESSION_TTL="12h"
# export AWS_ASSUME_ROLE_TTL="1h"
# export AWS_SESSION_TTL="12h" # healthline default session duration

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

# Set up basic pager colors
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

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

# Zoxide settings
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

    # Export extra secrets as environment variables
    # export GITHUB_OAUTH_TOKEN="$(get_secret GITHUB_OAUTH_TOKEN)"
    # export PAGERDUTY_TOKEN="$(get_secret pagerduty_token)"

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

    # Export secrets as environment variables
    # export NPM_TOKEN="$(get_secret tokens/npm)"
    # export PAGERDUTY_TOKEN="$(get_secret tokens/pagerduty)"
    # export GITHUB_TOKEN="$(get_secret tokens/github_oauth)"
fi

# plugins+=(zsh-autosuggestions zsh-syntax-highlighting)

#####################
# Misc Configurations
#####################

# Bash hotkey for end of line kill
bindkey \^U backward-kill-line

# Use vim keys in tab complete menu
# bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
# bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history
# bindkey -v '^?' backward-delete-char

# Use highlight for better less/more colors
# export LESSOPEN="| $(which highlight) %s --out-format xterm256 -l --force -s moria --no-trailing-nl"
# export LESS=" -R"
# alias less='less -m -N -g -i -J --underline-special'
# alias more='less'

# kubectx/kubens completions
fpath=($ZSH/functions $ZSH/completions $fpath)

###############
# Shell startup
###############

### Allow autocomplete for aliases
setopt complete_aliases

# 1password
source "$HOME"/.config/op/plugins.sh

# FZF (assume ripgrep is installed)
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git/*"'
export FZF_CTRL_T_COMMAND='rg --files --hidden -g "!.git/*"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Ondir configuration
# eval_ondir() {
#   eval "`ondir \"$OLDPWD\" \"$PWD\"`"
# }

# chpwd_functions=(eval_ondir $chpwd_functions)

# Starship
eval "$(starship init zsh)"
# Zoxide
eval "$(zoxide init zsh)"
# Misc
eval "$(thefuck --alias f -y)"
# Goenv
eval "$(goenv init -)"
# Direnv
eval "$(direnv hook zsh)"
