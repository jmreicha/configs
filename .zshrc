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
  ansible
  aws
  git
  docker
  docker-compose
  vagrant
  golang
  jsontools
  virtualenv
  pip
  kube-ps1
  terraform
  python
  kubectl
  history
  zsh-autosuggestions
  zsh-syntax-highlighting
  fzf
  fancy-ctrl-z
  extract
  nvm
  uv
)

# Load here to be able to source extra plugins and configurations like zsh-autosuggestions and zsh-syntax-highlighting
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
alias python="python3"
# alias pip="pip3"
# alias ccat="bat --paging=never"
alias ccat="highlight $1 --out-format xterm256 --force -s moria --no-trailing-nl"
alias e="exit"
alias rg="rg --hidden -g '!.git/'"
alias q="chatblade"
alias ff="fzf --preview 'bat {} --color=always --style=numbers --theme=1337'"

# Docker
alias d="docker"
alias dc="docker-compose"
alias dm="docker-machine"
alias dp="docker ps"
alias di="docker images"

# Kubernetes
alias k="kubectl"
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
alias ls='eza -a'
alias ll='eza --group --header --group-directories-first --long'
alias l='eza -lbGF --git'
alias la='eza -lbhHigmuSa --time-style=long-iso --git --color-scale'
alias lt='eza --tree --level=2'

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

# Okta
# AWS_OKTA_SESSION_CACHE_SINGLE_ITEM=true

# Export SSH key so it doesn't need to be passed in every time.
export SSH_KEY_PATH="~/.ssh/id_rsa"

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

# Home user bin directory
export PATH="$HOME/bin:$PATH"

# Bin
export PATH="/usr/local/bin:$PATH"

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

# hstr
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm

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
# eval_ondir() {
#   eval "`ondir \"$OLDPWD\" \"$PWD\"`"
# }

chpwd_functions=( eval_ondir $chpwd_functions )

# To customize our prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

### Autocomplete
autoload -U compinit && compinit

# Starship
eval "$(starship init zsh)"
# Zoxide
eval "$(zoxide init zsh)"
# Misc
eval $(thefuck --alias f -y)
# Goenv
eval "$(goenv init -)"
# Direnv
eval "$(direnv hook zsh)"
