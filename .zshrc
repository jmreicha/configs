######
# Misc
######

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.  Look in ~/.oh-my-zsh/themes/
#ZSH_THEME="af-magic"
ZSH_THEME="josh-custom"

# Better terminal colors
export TERM="xterm-256color"

# Bash hotkey for end of line kill
bindkey \^U backward-kill-line

# Not sure if this is working
setopt HIST_IGNORE_ALL_DUPS

# Helm tab completion
#source <(helm completion bash)

# Set default kubernetes diff
#export KUBERNETES_EXTERNAL_DIFF=colordiff

##################
# Custom functions
##################

dclean() {
    docker rm $(docker ps -aq --filter status=exited)
    docker rmi $(docker images -q --filter dangling=true)
    docker volume rm $(docker volume ls -qf dangling=true)
}

#########
# Aliases
#########

# Misc
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias z="vim ~/.zshrc"
alias v="vim ~/.vimrc"
alias ip="ip -c"
alias ccat="bat"

# Docker Compose
alias dc="docker-compose"
alias dm="docker-machine"
alias dp="docker ps"
alias di="docker images"

# Kubernetes
alias kgpa="kgp -o wide --all-namespaces"
alias kgn="kubectl get nodes -o wide"
alias ktn="kubectl top nodes"
alias ktp="kubectl top pods --all-namespaces"
alias ktpa="k top pods --all-namespaces"
alias kctx="kubectx"
alias kns="kubens"
alias kdump="kubectl get all --all-namespaces"
alias klft="klf --tail 100"

##############
# System paths
##############

# Krew k8s package manager
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Python3 (OSX)
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# RVM
#export PATH="$PATH:$HOME/.rvm/bin"

# MAN
#export MANPATH="/usr/local/man:$MANPATH"

# GO
<<<<<<< HEAD
#export GOPATH=$HOME/Go
export GOROOT=/usr/lib/go-1.11
export GOPATH=/usr/lib/go-1.11/bin
export PATH="$PATH:$GOPATH:$GOPATH/bin"
=======
export PATH=$PATH:/usr/local/opt/go/libexec/bin
#export GOPATH=$HOME/Go
#export GOROOT=/usr/local/opt/go/libexec
#export PATH=$PATH:$GOPATH/bin
>>>>>>> 0a7d05eb3ec5e6e045e7c49e476e182ba503f4f2
#export PATH=$PATH:$GOROOT/bin

# Terraform
#PATH=/usr/local/terraform/bin:$HOME/terraform:$PATH

#######################
# Environment variables
#######################

# Kubernetes PS1 prompt
#source /usr/local/opt/kube-ps1/share/kube-ps1.sh
#PROMPT='$(kube_ps1)'$PROMPT
#KUBE_PS1_BINARY="/usr/local/bin/kubectl"

# hstr
export HISTFILE=~/.zsh_history
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm
bindkey -s "\C-r" "\eqhh\n"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# This causes 'complete:13: command not found: compdef' error
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Export SSH key so it doesn't need to be passed in every time.
export SSH_KEY_PATH="~/.ssh/id_rsa"

# You may need to manually set your language environment
#export LANG=en_US.UTF-8

# Compilation flags
#export ARCHFLAGS="-arch x86_64"

# Owner
#export USER_NAME="YOUR NAME"

##############################
# Virtual environment settings
##############################

# Pyenv pip
export PATH="$HOME/.local/bin:$PATH"
# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

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

#####
# Zsh
#####

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Disable automatic text highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/issues/349
zle_highlight+=(paste:none)

# Plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Add wisely, as too many plugins slow down shell startup.
plugins=(ansible git docker vagrant go common-aliases jsontools virtualenv pip
        python osx kubectl helm zsh-autosuggestions)

# Zsh autosuggestion highlighting - grey
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="mm/dd/yyyy"

# Load extra configurations
source $ZSH/oh-my-zsh.sh

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin
