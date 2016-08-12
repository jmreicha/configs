# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="af-magic"

# Docker aliases
alias dc="docker-compose"
alias dm="docker-machine"
alias dp="docker ps"
alias di="docker images"
alias me-config='docker run -it --rm aboutdotme/config'

# Misc aliases
alias vimrc="vim ~/.vimrc"
alias zshrc="vim ~/.zshrc"
alias z="vim ~/.zshrc"
alias v="vim ~/.vimrc"

# GO paths
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Export SSH key so it doesn't need to be passed in every time.
#export SSH_KEY_PATH="~/.ssh/dsa_id"

# Paths
export PATH=$HOME/bin:/usr/local/bin:$PATH
# Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.rvm/bin"
# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# Plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Add wisely, as too many plugins slow down shell startup.
plugins=(git docker knife vagrant go common-aliases jsontools)

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

source $ZSH/oh-my-zsh.sh

# thefuck settings
eval $(thefuck --alias)

# Terraform
PATH=/usr/local/terraform/bin:$HOME/terraform:$PATH

# Dockerize settings
export PATH=$PATH:/Users/jmreicha/github.com/docker-dev
export COMPOSE_PROJECT_NAME=dev
#eval $(docker-machine env dev)
alias dc="docker-compose"
alias dm="docker-machine"
export MACHINE_IP=192.168.99.100

# Dockerize environment variables and aliases
source /Users/jmreicha/.dockerizerc
