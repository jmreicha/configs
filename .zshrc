#####
# ZSH
#####

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Look in ~/.oh-my-zsh/themes/
# ZSH_THEME="josh-custom"
ZSH_THEME="powerlevel10k/powerlevel10k"

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
plugins=(ansible aws git docker docker-compose vagrant golang jsontools
    virtualenv pip osx kube-ps1 zsh-syntax-highlighting terraform python kubectl
    helm zsh-autosuggestions fd fzf fancy-ctrl-z extract nvm)

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

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

#########
# Aliases
#########

# Misc
# alias cdr=$(git rev-parse --show-toplevel)
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias zz="vim ~/.zshrc"
alias v="vim ~/.vimrc"
alias diff="colordiff -u"
alias github="cd ~/github.com"
alias healthline="cd ~/github.com/healthline"
alias redventures="cd ~/github.com/redventures"
alias live="cd ~/github.com/healthline/infrastructure-live"
alias modules="cd ~/github.com/healthline/infrastructure-modules"
alias sandbox="cd ~/github.com/healthline/infrastructure-live-sandbox"
alias diff="colordiff"
alias python="python3"
# alias pip="pip3"
# Better cat
# alias ccat="bat --paging=never"
alias ccat="highlight $1 --out-format xterm256 --force -s moria --no-trailing-nl"
alias e="exit"
alias rg="rg --hidden -g '!.git/'"

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
alias ao="aws-okta"

# Exa
alias ls='exa -a'
alias ll='exa -lbFa --git --header'
alias l='exa -lbGF --git'
alias la='exa -lbhHigmuSa --time-style=long-iso --git --color-scale'
alias lt='exa --tree --level=2'

# Open specific files types automatically
alias -s tf=$EDITOR
alias -s tfvars=$EDITOR
alias -s hcl=$EDITOR
alias -s md=$EDITOR
alias -s markdown=$EDITOR
alias -s txt=$EDITOR

#########
# Exports
#########

# GPG key
export GPG_TTY=$(tty)
# export SOPS_PGP_FP="2AF2A2053D553C2FAE789DD6A9752A813F1EF110"

# GO
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$PATH:$GOROOT/bin:$GOPATH/bin

# Better terminal colors
export TERM="xterm-256color"

# Set default kubernetes diff
export KUBECTL_EXTERNAL_DIFF=colordiff

# AWS
export AWS_PAGER=""
# export AWS_SESSION_TTL="12h"
# export AWS_ASSUME_ROLE_TTL="1h"
# export AWS_SESSION_TTL="12h" # healthline default session duration

# Okta
# AWS_OKTA_SESSION_CACHE_SINGLE_ITEM=true

# Export SSH key so it doesn't need to be passed in every time.
export SSH_KEY_PATH="~/.ssh/id_rsa"

# Set the terraform/terragrunt cache in one place
export TERRAGRUNT_DOWNLOAD=${HOME}/.terragrunt/cache
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

# Zoxide settings
export _ZO_FZF_OPTS="--height 40%"

# Compilation flags
#export ARCHFLAGS="-arch x86_64"

# Owner
#export USER_NAME="YOUR NAME"

###########
# Functions
###########

aws-ssh() {
    aws-vault exec $1 -- aws ssm start-session --target $2
}

describe-instances() {
    aws-vault exec $1 -- aws ec2 describe-instances | jq -r ".Reservations[].Instances[] | [.InstanceId, .NetworkInterfaces[].PrivateIpAddress, (.Tags[]?|select(.Key==\"Name\")|.Value)]"
}

dclean() {
    docker rm $(docker ps -aq --filter status=exited)
    docker rmi $(docker images -q --filter dangling=true)
    docker volume rm $(docker volume ls -qf dangling=true)
}

# list environment variables
list_env() {
  local var
  var=$(printenv | cut -d= -f1 | fzf) && echo "$var=${(P)var}"
}

#######
# Paths
#######

# Krew k8s package manager
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Pulumi
export PATH="$HOME/.pulumi/bin:$PATH"

# Home user bin directory
export PATH="$HOME/bin:$PATH"

# Bin
export PATH="/usr/local/bin:$PATH"

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
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/projects

# virtualenv-burrito
if [ -f $HOME/.venvburrito/startup.sh ]; then
    . $HOME/.venvburrito/startup.sh
fi

###############
# Powerlevel10k
###############

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#############
# OS Specific
#############

### OSX
if [[ $(uname) == "Darwin" ]]; then
    echo "Loading additional OSX configuration"

    # Python3
    export PATH=$PATH:/$HOME/Library/Python/3.9/bin/

    # Terraform autocompletion
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /Users/jreichardt/.tfenv/versions/0.12.29/terraform terraform

    # Autojump
    [ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

    # Retrieve a secret from osx keychain
    get_secret() {
        security find-generic-password -gs "${1}" -w
    }

    # virtualenvwrapper
    export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
    export VIRTUALENVWRAPPER_VIRTUALENV=/Users/jreichardt/Library/Python/3.9/bin/virtualenv
    source /Users/jreichardt/Library/Python/3.9/bin/virtualenvwrapper.sh

    # Export secrets as environment variables
    # export DATADOG_API_KEY="$(get_secret dd_frontend_preprod_api)"
    # export DATADOG_APP_KEY="$(get_secret dd_frontend_preprod_app)"
    export GITHUB_OAUTH_TOKEN="$(get_secret GITHUB_OAUTH_TOKEN)"
    export PAGERDUTY_TOKEN="$(get_secret pagerduty_token)"
fi

### Linux
if [[ $(uname) == "Linux" ]]; then
    echo "Loading additional Linux configuration"

    alias ip="ip -c"

    # OS specific configs
    if cat /etc/os-release | grep ID=debian; then
        alias fd="fdfind"
        export PATH=$PATH:/$HOME/.local/bin
    fi
    alias fd="fdfind --hidden"

    # Credentials are stored in gpg/pass
    export AWS_VAULT_BACKEND="pass"

    # Python3
    #export PATH="/usr/local/opt/python/libexec/bin:$PATH"
    export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
    export VIRTUALENVWRAPPER_VIRTUALENV=~/.local/bin/virtualenv
    source ~/.local/bin/virtualenvwrapper.sh

    # Retrieve a secret from pgp pass backend
    get_secret() {
        pass show "$1"
    }

    # Export secrets as environment variables
    export NPM_TOKEN="$(get_secret tokens/npm)"
    export PAGERDUTY_TOKEN="$(get_secret tokens/pagerduty)"
    # export GITHUB_TOKEN="$(get_secret tokens/github_oauth)"
fi

plugins+=(virtualenvwrapper)

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

# kube-ps1 prompt comes after the plugin is enabled and extra config is loaded
# PROMPT=$PROMPT'$(kube_ps1) '
# KUBE_PS1_SYMBOL_ENABLE=false
# KUBE_PS1_ENABLED=off

# hstr
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm
bindkey -s "\C-r" "\eqhh\n"

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# kubectx/kubens completions
fpath=($ZSH/functions $ZSH/completions $fpath)

###############
# Shell startup
###############

# FZF (assume ripgrep is installed)
export FZF_DEFAULT_COMMAND='rg --files --hidden -g "!.git/*"'
export FZF_CTRL_T_COMMAND='rg --files --hidden -g "!.git/*"'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Ondir configuration
eval_ondir() {
  eval "`ondir \"$OLDPWD\" \"$PWD\"`"
}

chpwd_functions=( eval_ondir $chpwd_functions )

# To customize our prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### Autocomplete
autoload -U compinit && compinit

# Starship
# eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
