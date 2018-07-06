######
# Misc
######

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.  Look in ~/.oh-my-zsh/themes/
ZSH_THEME="af-magic"

# Bash end of line kill
bindkey \^U backward-kill-line

#######################
# Environment variables
#######################

# Kubernetes PS1 prompt
#source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
#PROMPT='$(kube_ps1)'$PROMPT
#KUBE_PS1_BINARY="/usr/local/bin/kubectl"

# hstr
export HISTFILE=~/.zsh_history
export HH_CONFIG=keywords,hicolor,rawhistory,noconfirm
bindkey -s "\C-r" "\eqhh\n"

# Python3 path
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
# RVM
#export PATH="$PATH:$HOME/.rvm/bin"
# MAN
#export MANPATH="/usr/local/man:$MANPATH"
# GO
#export GOPATH=$HOME/go
#export PATH=$PATH:$GOPATH/bin
# Terraform
#PATH=/usr/local/terraform/bin:$HOME/terraform:$PATH

# Virtual Environment
#export WORKON_HOME=$HOME/.virtualenvs
#export PROJECT_HOME=$HOME/projects
#source /usr/local/bin/virtualenvwrapper.sh

# Virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
# This seems to break with custom path for Python3
#source /usr/local/bin/virtualenvwrapper.sh

# virtualenv-burrito
#if [ -f $HOME/.venvburrito/startup.sh ]; then
#    . $HOME/.venvburrito/startup.sh
#fi

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# This causes 'complete:13: command not found: compdef' error
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Export SSH key so it doesn't need to be passed in every time.
export SSH_KEY_PATH="~/.ssh/id_rsa"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Owner
#export USER_NAME="YOUR NAME"

#########
# Aliases
#########

# Docker aliases
alias dc="docker-compose"
alias dm="docker-machine"
alias dp="docker ps"
alias di="docker images"

# Compose aliases
alias dc="docker-compose"
alias dm="docker-machine"

# Kubernetes aliases
alias kgpa="kgp --all-namespaces"
alias kgn="k get nodes"
alias ktn="k top nodes"
alias ktp="k top pods"
alias ktpa="k top pods --all-namespaces"

# Misc aliases
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias z="vim ~/.zshrc"
alias v="vim ~/.vimrc"

# Helm tab completion
#source <(helm completion bash)

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
plugins=(ansible git docker vagrant go common-aliases jsontools virtualenv pip python osx kubectl helm)

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

source $ZSH/oh-my-zsh.sh
