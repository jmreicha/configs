#####
# ZSH
#####

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Look in ~/.oh-my-zsh/themes/
ZSH_THEME="josh-custom"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

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
plugins=(ansible git docker vagrant golang jsontools virtualenv pip autojump osx
        terraform python kubectl helm zsh-autosuggestions aws timer fd
        kube-ps1 zsh-syntax-highlighting)

# Load here to be able to source extra plugins and configurations
source $ZSH/oh-my-zsh.sh

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

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

#########
# Aliases
#########

# Misc
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias z="vim ~/.zshrc"
alias v="vim ~/.vimrc"
alias ccat="bat --paging=never"
alias diff="colordiff -u"
alias github="cd ~/github.com"
alias live="cd ~/github.com/healthline/infrastructure-live"
alias live="cd ~/github.com/healthline/infrastructure-modules"
alias diff="colordiff"
alias python="python3"
alias pip="pip3"

# Docker
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
alias dp="docker ps"
alias di="docker images"

# Kubernetes
alias kw="watch kubectl get pods"
alias kgpa="kgp --all-namespaces"
alias kgpaw="kgp -o wide --all-namespaces"
alias kgn="kubectl get nodes -o wide"
alias kdn="kubectl describe nodes"
alias ktn="kubectl top nodes"
alias ktp="kubectl top pods --all-namespaces"
alias ktpa="k top pods --all-namespaces"
alias kctx="kubectx"
alias kns="kubens"
alias kdump="kubectl get all --all-namespaces"
alias klft="klf --tail 100"
alias ktop="k9s -n all"

# Terraform
alias tf="terraform"
alias tg="terragrunt"

# AWS
alias av="aws-vault"

# Open specific files types automatically
alias -s bash=$EDITOR
alias -s sh=$EDITOR
alias -s tf=$EDITOR
alias -s tfvars=$EDITOR
alias -s md=$EDITOR
alias -s markdown=$EDITOR
alias -s txt=$EDITOR
alias -s py=$EDITOR
alias -s js=$EDITOR
alias -s css=$EDITOR
alias -s html=$EDITOR
alias -s htm=$EDITOR

#########
# Exports
#########

# Options for timer plugin
export TIMER_FORMAT="# %d"
export TIMER_PRECISION="3"

# Better terminal colors
export TERM="xterm-256color"

# Set default kubernetes diff
export KUBECTL_EXTERNAL_DIFF=colordiff

# AWS
export AWS_SESSION_TTL="12h"
export AWS_ASSUME_ROLE_TTL="1h"

# Export SSH key so it doesn't need to be passed in every time.
export SSH_KEY_PATH="~/.ssh/id_rsa"

# Set the terragrunt cache in one place
export TERRAGRUNT_DOWNLOAD=${HOME}/.terragrunt/cache

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

# You may need to manually set your language environment
#export LANG=en_US.UTF-8

# Compilation flags
#export ARCHFLAGS="-arch x86_64"

# Owner
#export USER_NAME="YOUR NAME"

###########
# Functions
###########

dclean() {
    docker rm $(docker ps -aq --filter status=exited)
    docker rmi $(docker images -q --filter dangling=true)
    docker volume rm $(docker volume ls -qf dangling=true)
}

# TODO Better paging using highlight
# cless() {
# }

#######
# Paths
#######

# Krew k8s package manager
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Pulumi
export PATH=$PATH:$HOME/.pulumi/bin

########
# Python
########

# Pyenv pip
export PATH="$HOME/.local/bin:$PATH"

# Pyenv
#export PATH="$HOME/.pyenv/bin:$PATH"
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

# Virtualenvwrapper
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"
#export WORKON_HOME=$HOME/.virtualenvs
#export PROJECT_HOME=$HOME/projects
#export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
#export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
# This seems to break with custom path for Python3
#source /usr/local/bin/virtualenvwrapper.sh

# virtualenv-burrito
if [ -f $HOME/.venvburrito/startup.sh ]; then
    . $HOME/.venvburrito/startup.sh
fi

#############
# OS Specific
#############

### OSX
if [[ $(uname) == "Darwin" ]]; then
    echo "Loading additional OSX configuration"

    # Python3
    export PATH=$PATH:/$HOME/Library/Python/3.7/bin/

    # Terraform autocompletion
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /usr/local/Cellar/terraform/0.11.13/bin/terraform terraform

    # Autojump
    [ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

    # kube-ps1
    # source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"

    # Retrieve a secret from osx keychain
    get_secret() {
        security find-generic-password -gs "${1}" -w
    }

    # Export secrets as environment variables
    # export DATADOG_API_KEY="$(get_secret dd_frontend_preprod_api)"
    # export DATADOG_APP_KEY="$(get_secret dd_frontend_preprod_app)"
fi

### Linux
if [[ $(uname) == "Linux" ]]; then
    echo "Loading additional Linux configuration"

    alias ip="ip -c"
    alias fd="fdfind"

    # Credentials are stored in gpg/pass
    export AWS_VAULT_BACKEND="pass"

    # Python3
    #export PATH="/usr/local/opt/python/libexec/bin:$PATH"

    # Enable AWS autocompletion on Linux with non standard path
    source ~/.local/bin/aws_zsh_completer.sh

    # Retrieve a secret from pgp pass backend
    get_secret() {
        pass show "$1"
    }

    # Export secrets as environment variables
    export NPM_TOKEN="$(get_secret tokens/npm)"
    export PAGERDUTY_TOKEN="$(get_secret tokens/pagerduty)"
fi

#####################
# Misc Configurations
#####################

# Bash hotkey for end of line kill
bindkey \^U backward-kill-line

# kube-ps1 prompt comes after the plugin is enabled and extra config is loaded
PROMPT=$PROMPT'$(kube_ps1) '
KUBE_PS1_SYMBOL_ENABLE=false
KUBE_PS1_ENABLED=off

# hstr
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm
bindkey -s "\C-r" "\eqhh\n"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# This causes 'complete:13: command not found: compdef' error
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# FZF (assume ripgrep is installed)
# export FZF_DEFAULT_OPTS='--ansi'
# export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/*"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# kubectx/kubens completions
fpath=($ZSH/functions $ZSH/completions $fpath)
autoload -U compinit && compinit

# Ondir configuration
eval_ondir() {
  eval "`ondir \"$OLDPWD\" \"$PWD\"`"
}

chpwd_functions=( eval_ondir $chpwd_functions )
